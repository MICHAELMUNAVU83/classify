defmodule Classify.FileParser do
  @moduledoc """
  Parses uploaded CSV and Excel files into product structs.
  """

  @doc """
  Parse a file and return a list of product maps.
  Supports CSV and XLSX formats.
  """
  def parse_file(file_path) do
    cond do
      String.ends_with?(file_path, ".csv") ->
        parse_csv(file_path)

      String.ends_with?(file_path, [".xlsx", ".xls"]) ->
        parse_xlsx(file_path)

      true ->
        {:error, "Unsupported file format. Please upload CSV or XLSX files."}
    end
  end

  @doc """
  Parse CSV file into product list
  """
  def parse_csv(file_path) do
    try do
      products =
        File.stream!(file_path)
        |> CSV.decode!(headers: true)
        |> Enum.map(&normalize_product/1)
        |> Enum.reject(&is_nil/1)

      {:ok, products}
    rescue
      e ->
        {:error, "Failed to parse CSV: #{Exception.message(e)}"}
    end
  end

  @doc """
  Parse Excel file into product list
  """
  def parse_xlsx(file_path) do
    try do
      {:ok, tid} = Xlsxir.multi_extract(file_path, 0)

      # Get all rows from the first sheet
      rows = Xlsxir.get_list(tid)
      Xlsxir.close(tid)

      # First row should be headers
      [headers | data_rows] = rows

      # Normalize headers (Xlsxir may return numbers/other types)
      headers = Enum.map(headers, &normalize_header/1)

      # Convert rows to maps
      products =
        data_rows
        |> Enum.map(fn row ->
          headers
          |> Enum.zip(pad_row(row, length(headers)))
          |> Map.new()
          |> normalize_product()
        end)
        |> Enum.reject(&is_nil/1)

      {:ok, products}
    rescue
      e ->
        {:error, "Failed to parse Excel: #{Exception.message(e)}"}
    end
  end

  defp pad_row(row, expected_len) do
    len = length(row)
    if len >= expected_len do
      Enum.take(row, expected_len)
    else
      row ++ List.duplicate(nil, expected_len - len)
    end
  end

  # Private Functions

  defp normalize_header(header) when is_binary(header) do
    header
    |> String.downcase()
    |> String.trim()
    |> String.to_atom()
  end

  defp normalize_header(header) when is_number(header) or is_atom(header) do
    header |> to_string() |> String.downcase() |> String.to_atom()
  end

  defp normalize_header(_), do: :unknown

  defp normalize_product(raw_product) when is_map(raw_product) do
    # Handle different possible column names
    code = get_value(raw_product, [:code, :product_code, :sku, :barcode, "code"])
    name = get_value(raw_product, [:name, :product_name, :title, "name"])

    description =
      get_value(raw_product, [:description, :desc, :product_description, "description"])

    weight = get_value(raw_product, [:weight, :size, :quantity, "weight"])
    uom = get_value(raw_product, [:uom, :unit, :unit_of_measure, "uom"])

    classification =
      get_value(raw_product, [:classification, :brick, :brick_code, :category, "classification"])

    target_market = get_value(raw_product, [:target_market, :market, :country, "target_market"])

    # Only return if we have minimum required fields
    if code && (name || description) do
      %{
        code: to_string(code),
        name: to_string(name || ""),
        description: to_string(description || ""),
        weight: parse_number(weight),
        uom: to_string(uom || ""),
        classification: parse_number(classification),
        target_market: to_string(target_market || "")
      }
    else
      nil
    end
  end

  defp normalize_product(_), do: nil

  defp get_value(map, keys) when is_list(keys) do
    Enum.find_value(keys, fn key ->
      Map.get(map, key) || Map.get(map, to_string(key))
    end)
  end

  defp parse_number(nil), do: nil
  defp parse_number(value) when is_number(value), do: value

  defp parse_number(value) when is_binary(value) do
    case Float.parse(value) do
      {num, _} -> num
      :error -> nil
    end
  end

  defp parse_number(_), do: nil
end
