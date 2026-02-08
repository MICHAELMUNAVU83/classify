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
  extract or infer: weight (numeric, e.g. 300, 1.5), uom (unit: MLT or LTR only),
  classification (GS1 brick code, 8 digits as string), target_market (country code e.g. KE).
  For description: combine product name/type with volume and unit in one string, in sentence case (first letter capital, rest lowercase).
  Format: "Product name [weight][uom]" e.g. "Vesen purified water 300mlt", "Breast cancer initiative purified water 500mlt".
  Return a JSON array with one object per product in the SAME order as given. Each object must have exactly:
  description (string, product name + space + volume + unit as above), weight (number or null), uom (string "MLT" or "LTR" or null), classification (string 8 digits or null), target_market (string 2-letter code or null).
  If you cannot determine a value, use null. Return only the JSON array, no other text.
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
        "code: #{p.code}, name: #{p.name}, description: #{p.description}"
      end)

    "Products (one per line):\n" <> Enum.join(lines, "\n") <>
      "\n\nReturn a JSON array of objects with keys: description (product name + volume + unit e.g. 'Breast Cancer Initiative Purified Water 500mlt'), weight, uom, classification, target_market (same order as above)."
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
    raw = if is_binary(ai_row["description"]) and String.trim(ai_row["description"]) != "", do: String.trim(ai_row["description"]), else: product.description
    cleaned_desc = sentence_case(raw)

    product
    |> Map.put(:description, cleaned_desc)
    |> Map.put(:weight, pick_number(ai_row["weight"], product.weight))
    |> Map.put(:uom, pick_string(ai_row["uom"], product.uom, ~w(MLT LTR)))
    |> Map.put(:classification, pick_classification(ai_row["classification"], product.classification))
    |> Map.put(:target_market, pick_string(ai_row["target_market"], product.target_market, nil) || "KE")
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

  defp to_seven_attributes_only(product) do
    classification = product[:classification] || product["classification"]
    classification_str = if is_binary(classification), do: classification, else: if(is_number(classification), do: to_string(classification), else: nil)
    target = product[:target_market] || product["target_market"]
    target_str = if present?(target), do: to_string(target), else: "KE"

    %{
      code: to_string(product[:code] || product["code"] || ""),
      name: to_string(product[:name] || product["name"] || ""),
      description: to_string(product[:description] || product["description"] || ""),
      weight: product[:weight] || product["weight"],
      uom: to_string(product[:uom] || product["uom"] || ""),
      classification: classification_str,
      target_market: target_str
    }
  end
end
