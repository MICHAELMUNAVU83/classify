defmodule Classify.ProductChatbot do
  @moduledoc """
  Interprets natural-language bulk-edit commands from the user and returns
  a structured operation map that the LiveView can apply to reviewed_products.
  """

  alias Classify.OpenAI

  @system_prompt """
  You are a bulk data editor for product records.
  The user gives natural-language instructions to modify a list of product maps.

  Each product has these fields:
    code, name, description, weight (number), uom, classification, target_market

  Valid values:
    target_market: "KE" (Kenya), "UG" (Uganda), "001" (global/worldwide)
    uom: MLT, LTR, CTL, GRM, KGM, MTR, CMT, MMT, INH, PK, PA, DZN, PR, ZP, H87, U2, AV, ONZ, LTN, AMP, KWT, WTT, VLT, KVT
    classification: 8-digit GS1 brick code string

  Return ONLY a JSON object — no markdown, no extra text.

  Possible response shapes:

  1. Change a field for ALL products:
     { "op": "set_all", "field": "<field>", "value": "<new_value>",
       "summary": "Human-readable summary of what was done" }

  2. Change a field only for products where another field matches a condition:
     { "op": "set_where",
       "field": "<field_to_change>", "value": "<new_value>",
       "where_field": "<field_to_filter_on>",
       "where_op": "contains" | "equals" | "starts_with" | "ends_with",
       "where_value": "<filter_text>",
       "summary": "Human-readable summary of what was done" }

  3. Cannot understand or execute the command:
     { "op": "error", "summary": "Short explanation of why" }

  Examples:
    "Make the target market for all 001"
      → { "op": "set_all", "field": "target_market", "value": "001",
           "summary": "Set target_market to 001 (global) for all products" }

    "Change the classification for all coffee products to 10005514"
      → { "op": "set_where", "field": "classification", "value": "10005514",
           "where_field": "description", "where_op": "contains", "where_value": "coffee",
           "summary": "Set classification to 10005514 for all products whose description contains 'coffee'" }

    "Set UOM to GRM for everything"
      → { "op": "set_all", "field": "uom", "value": "GRM",
           "summary": "Set uom to GRM for all products" }
  """

  @doc """
  Parse a user command and return {:ok, op_map} or {:error, reason}.
  op_map has at minimum: op, summary, and the fields needed to apply the change.
  """
  def parse_command(command, product_sample \\ []) do
    context = build_context(product_sample)

    case OpenAI.send_request_to_openai(@system_prompt, context <> "\n\nUser command: " <> command) do
      {:ok, content} ->
        json_str =
          content
          |> String.trim()
          |> String.replace(~r/^```(?:json)?\s*/i, "")
          |> String.replace(~r/\s*```\s*$/i, "")

        case Jason.decode(json_str) do
          {:ok, %{"op" => "error", "summary" => msg}} ->
            {:error, msg}

          {:ok, %{"op" => op} = result} when op in ["set_all", "set_where"] ->
            {:ok, result}

          {:ok, _} ->
            {:error, "Unrecognised response from AI."}

          {:error, _} ->
            {:error, "Could not parse AI response."}
        end

      {:error, _} ->
        {:error, "Could not reach AI service."}
    end
  end

  @doc """
  Apply an op_map returned by parse_command/2 to a list of product maps.
  Returns {updated_products, affected_count}.
  """
  def apply_op(products, %{"op" => "set_all", "field" => field, "value" => value}) do
    atom = safe_atom(field)
    updated = Enum.map(products, fn p -> put_field(p, atom, value) end)
    {updated, length(updated)}
  end

  def apply_op(products, %{
        "op" => "set_where",
        "field" => field,
        "value" => value,
        "where_field" => wf,
        "where_op" => wop,
        "where_value" => wv
      }) do
    atom = safe_atom(field)
    wf_atom = safe_atom(wf)
    wv_down = String.downcase(wv)

    {updated, count} =
      Enum.map_reduce(products, 0, fn p, acc ->
        field_val = to_string(p[wf_atom] || p[wf] || "") |> String.downcase()

        matches =
          case wop do
            "contains" -> String.contains?(field_val, wv_down)
            "equals" -> field_val == wv_down
            "starts_with" -> String.starts_with?(field_val, wv_down)
            "ends_with" -> String.ends_with?(field_val, wv_down)
            _ -> false
          end

        if matches do
          {put_field(p, atom, value), acc + 1}
        else
          {p, acc}
        end
      end)

    {updated, count}
  end

  def apply_op(products, _), do: {products, 0}

  # ── private helpers ────────────────────────────────────────────────────────

  defp build_context([]), do: ""

  defp build_context(sample) do
    lines =
      sample
      |> Enum.take(5)
      |> Enum.map(fn p ->
        "  code=#{p[:code]}, name=#{p[:name]}, desc=#{p[:description]}, " <>
          "uom=#{p[:uom]}, market=#{p[:target_market]}, class=#{p[:classification]}"
      end)

    "Current product sample (first #{length(lines)}):\n" <> Enum.join(lines, "\n")
  end

  @allowed_fields ~w(code name description weight uom classification target_market)

  defp safe_atom(f) when is_binary(f) do
    if f in @allowed_fields, do: String.to_existing_atom(f), else: :__unknown__
  end

  defp put_field(p, :__unknown__, _v), do: p
  defp put_field(p, key, value), do: Map.put(p, key, value)
end
