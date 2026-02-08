defmodule Classify.ExportXlsx do
  @moduledoc """
  Builds an XLSX binary from a list of product maps. Uses Elixlsx.
  """

  @doc """
  Returns {:ok, binary} or {:error, reason}.
  """
  def build(products) when is_list(products) do
    _ = Application.ensure_all_started(:elixlsx)
    with {:module, _} <- Code.ensure_loaded(Elixlsx.Sheet),
         {:module, _} <- Code.ensure_loaded(Elixlsx.Workbook) do
      do_build(products)
    else
      {:error, _} -> {:error, :elixlsx_not_available}
    end
  end

  defp do_build(products) do
    headers = ["code", "name", "description", "weight", "uom", "classification", "target_market"]
    rows =
      Enum.map(products, fn p ->
        [
          p.code,
          p.name,
          p.description,
          format(p.weight),
          p.uom,
          format(p.classification),
          p.target_market
        ]
      end)
    data = [headers | rows]

    sheet =
      Elixlsx.Sheet.with_name("Products")
      |> add_rows(0, data)

    workbook = Elixlsx.Workbook.append_sheet(struct(Elixlsx.Workbook, %{sheets: [], datetime: nil}), sheet)

    case Elixlsx.write_to_memory(workbook, "products.xlsx") do
      {:ok, {_name, binary}} -> {:ok, binary}
      other -> {:error, other}
    end
  rescue
    e -> {:error, Exception.message(e)}
  end

  defp format(nil), do: ""
  defp format(""), do: ""
  defp format(v) when is_binary(v), do: v
  defp format(v) when is_number(v), do: to_string(v)
  defp format(v), do: to_string(v)

  defp add_rows(sheet, _row_idx, []), do: sheet
  defp add_rows(sheet, row_idx, [row | rest]) do
    sheet =
      row
      |> Enum.with_index(0)
      |> Enum.reduce(sheet, fn {cell, col_idx}, acc ->
        Elixlsx.Sheet.set_at(acc, row_idx, col_idx, cell)
      end)
    add_rows(sheet, row_idx + 1, rest)
  end
end
