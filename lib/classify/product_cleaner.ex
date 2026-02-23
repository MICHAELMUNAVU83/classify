defmodule Classify.ProductCleaner do
  @moduledoc """
  Uses OpenAI to clean product records: extract weight, uom, classification, target_market
  from name/description when missing. Uses Classifications.relevant_for/2 to pass a short
  list of valid brick codes per batch (token-efficient).
  """

  alias Classify.OpenAI
  alias Classify.Classifications

  @base_context """
  You are a data cleaner for product records. Given product code, name, and description,
  extract or infer: brand name, description, weight, uom, classification, target_market.

  NAME RULES (extract brand name only — not product type):
  - name must be ONLY the brand/manufacturer name, in title case. Strip any product-type words.
  - "VESEN PURIFIED WATER" → name = "Vesen"
  - "BREAST CANCER INITIATIVE PURIFIED WATER" → name = "Breast Cancer Initiative"
  - "DAIRYFRESH FULL CREAM MILK 1L" → name = "Dairyfresh"
  - When unsure, keep only the first word(s) that identify the brand; drop generic product words like water, milk, juice, purified, fresh, cream, etc.

  DESCRIPTION RULES:
  - Full product name + volume + unit in sentence case, e.g. "Vesen purified water 300mlt".

  WEIGHT RULES (critical — do NOT convert between units):
  - weight is the raw numeric value from the product, matching the uom field.
  - If the product says "10 LITRES" → weight=10, uom="LTR"
  - If the product says "18.9 LITRES" → weight=18.9, uom="LTR"
  - If the product says "500ML" or "500mlt" → weight=500, uom="MLT"
  - If the product says "300ML" → weight=300, uom="MLT"
  - NEVER multiply by 1000 or otherwise convert the number. Keep the numeric value exactly as described.

  Classification: you will receive a list of valid brick codes with descriptions. Pick the ONE brick whose description best matches the product type. Use ONLY brick codes from that list; if none fit, use null.
  TARGET MARKET RULES:
  - Use ONLY one of: "KE" (Kenya), "UG" (Uganda), "001" (global/worldwide).
  - Default to "KE" if unknown or cannot be determined.

  Return a JSON array with one object per product in the SAME order as given. Each object: name (brand only, title case), description (string), weight (number or null), uom (one of: MLT, LTR, CTL, GRM, KGM, MTR, CMT, MMT, INH, PK, PA, DZN, PR, ZP, H87, U2, AV, ONZ, LTN, AMP, KWT, WTT, VLT, KVT — or null), classification (string 8 digits from the list or null), target_market ("KE", "UG", or "001").
  Return only the JSON array, no other text.
  """

  @doc """
  Clean a batch of products via OpenAI. Returns a list in the SAME order as input.
  Passes a compact list of relevant GS1 classifications to keep tokens low.
  """
  def analyse_batch(products) when is_list(products) and length(products) > 0 do
    prompt = build_batch_prompt(products)
    system_context = build_system_context(products)

    case OpenAI.send_request_to_openai(system_context, prompt) do
      {:ok, content} ->
        parse_and_merge(products, content)

      {:error, _} ->
        Enum.map(products, &to_seven_attributes_only/1)
    end
  end

  def analyse_batch([]), do: []

  defp build_system_context(products) do
    hint = Classifications.relevant_for(products, 80)
    if hint == "" do
      @base_context
    else
      @base_context <>
        "\n\nValid classification codes (use one of these brick codes or null; format brick\\tdescription):\n" <>
        hint
    end
  end

  defp build_batch_prompt(products) do
    lines =
      Enum.map(products, fn p ->
        base = "code: #{p.code}, name: #{p.name}, description: #{p.description}"
        tm = to_string(p[:target_market] || p["target_market"] || "") |> String.trim()

        hint =
          cond do
            tm in ["KE", "UG", "001"] -> ", market_hint: #{tm}"
            tm != "" -> ", market_hint: #{tm}"
            true -> ""
          end

        base <> hint
      end)

    "Products (one per line):\n" <> Enum.join(lines, "\n") <>
      "\n\nReturn a JSON array of objects with keys: name (brand only e.g. 'Vesen', 'Breast Cancer Initiative'), description (full product name + volume + unit e.g. 'Vesen purified water 300mlt'), weight, uom, classification, target_market.\n" <>
      "IMPORTANT: if market_hint is present, use it directly — '001' means global, 'KE' Kenya, 'UG' Uganda. Only override if the hint is clearly wrong."
  end

  defp parse_and_merge(products, content) do
    json_str =
      content
      |> String.trim()
      |> String.replace(~r/^```(?:json)?\s*/i, "")
      |> String.replace(~r/\s*```\s*$/i, "")

    case Jason.decode(json_str) do
      {:ok, list} when is_list(list) ->
        padded = list ++ List.duplicate(%{}, max(0, length(products) - length(list)))
        ai_rows = Enum.take(padded, length(products))

        Enum.zip(products, ai_rows)
        |> Enum.map(fn {product, ai_row} -> merge_ai_into_product(product, ai_row || %{}) end)
        |> Enum.map(&to_seven_attributes_only/1)

      _ ->
        Enum.map(products, &to_seven_attributes_only/1)
    end
  end

  defp merge_ai_into_product(product, ai_row) when is_map(ai_row) do
    raw_desc = if is_binary(ai_row["description"]) and String.trim(ai_row["description"]) != "", do: String.trim(ai_row["description"]), else: product.description
    cleaned_desc = sentence_case(raw_desc)

    raw_name = ai_row["name"]
    cleaned_name =
      if is_binary(raw_name) and String.trim(raw_name) != "" do
        String.trim(raw_name)
      else
        product.name
      end

    product
    |> Map.put(:name, cleaned_name)
    |> Map.put(:description, cleaned_desc)
    |> Map.put(:weight, pick_number(ai_row["weight"], product.weight))
    |> Map.put(:uom, pick_string(ai_row["uom"], product.uom, ~w(MLT LTR CTL GRM KGM MTR CMT MMT INH PK PA DZN PR ZP H87 U2 AV ONZ LTN AMP KWT WTT VLT KVT)))
    |> Map.put(:classification, pick_classification(ai_row["classification"], product.classification))
    |> Map.put(:target_market, pick_target_market(ai_row["target_market"], product.target_market))
  end

  # If the original (file-parsed) market is already "001" (multi-country), never
  # let the AI downgrade it to a single country — the file knows best here.
  defp pick_target_market(_ai, original) when original in ["001"], do: "001"
  defp pick_target_market(ai, original) do
    pick_string(ai, original, ~w(KE UG 001)) || "KE"
  end

  defp pick_number(nil, fallback), do: fallback
  defp pick_number(n, _) when is_number(n), do: n
  defp pick_number(s, fallback) when is_binary(s) do
    case Float.parse(s) do
      {num, _} -> num
      :error -> fallback
    end
  end
  defp pick_number(_, fallback), do: fallback

  defp pick_string(nil, fallback, _), do: if(is_binary(fallback) and fallback != "", do: String.upcase(fallback), else: nil)
  defp pick_string(s, _fallback, allowed) when is_binary(s) do
    s = String.trim(s) |> String.upcase()
    if s == "", do: nil, else: (if allowed && s not in allowed, do: nil, else: s)
  end
  defp pick_string(_, fallback, _), do: fallback

  defp sentence_case(nil), do: nil
  defp sentence_case(""), do: ""
  defp sentence_case(s) when is_binary(s) do
    s = String.trim(s)
    if s == "", do: "", else: String.capitalize(String.downcase(s))
  end

  defp pick_classification(nil, fallback), do: fallback
  defp pick_classification(s, _) when is_binary(s) do
    s = String.trim(s)
    if String.match?(s, ~r/^\d{8}$/), do: s, else: nil
  end
  defp pick_classification(n, _) when is_number(n), do: to_string(n)
  defp pick_classification(_, fallback), do: fallback

  defp present?(nil), do: false
  defp present?(""), do: false
  defp present?(v) when is_binary(v), do: String.trim(v) != ""
  defp present?(_), do: true

  # Avoid storing code as "6164003345002.0" when parsed as float
  defp normalize_code_for_output(nil), do: ""
  defp normalize_code_for_output(v) when is_integer(v), do: to_string(v)
  defp normalize_code_for_output(v) when is_number(v) do
    if trunc(v) == v, do: to_string(trunc(v)), else: to_string(v)
  end
  defp normalize_code_for_output(v) when is_binary(v) do
    s = String.trim(v)
    if String.ends_with?(s, ".0") and String.length(s) > 2 do
      rest = String.slice(s, 0, String.length(s) - 2)
      if rest =~ ~r/^\d+$/, do: rest, else: s
    else
      s
    end
  end
  defp normalize_code_for_output(v), do: to_string(v)

  defp to_seven_attributes_only(product) do
    classification = product[:classification] || product["classification"]
    classification_str = if is_binary(classification), do: classification, else: if(is_number(classification), do: to_string(classification), else: nil)
    target = product[:target_market] || product["target_market"]
    target_str =
      case to_string(target) |> String.trim() |> String.upcase() do
        t when t in ["KE", "UG", "001"] -> t
        _ -> "KE"
      end
    code_raw = product[:code] || product["code"] || ""

    %{
      code: normalize_code_for_output(code_raw),
      name: to_string(product[:name] || product["name"] || ""),
      description: to_string(product[:description] || product["description"] || ""),
      weight: product[:weight] || product["weight"],
      uom: to_string(product[:uom] || product["uom"] || ""),
      classification: classification_str,
      target_market: target_str
    }
  end
end
