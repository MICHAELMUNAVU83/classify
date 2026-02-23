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

  # ── Raw parsing (for the column-mapping step) ──────────────────────────────

  @doc """
  Parse a file and return the raw headers + rows without any field normalization.
  Returns {:ok, headers, rows} where headers is [String.t()] and rows is [map()].
  """
  def parse_file_raw(file_path) do
    cond do
      String.ends_with?(file_path, ".csv") -> parse_csv_raw(file_path)
      String.ends_with?(file_path, [".xlsx", ".xls"]) -> parse_xlsx_raw(file_path)
      true -> {:error, "Unsupported format"}
    end
  end

  def parse_csv_raw(file_path) do
    try do
      rows = File.stream!(file_path) |> CSV.decode!(headers: true) |> Enum.to_list()
      headers = if rows == [], do: [], else: rows |> hd() |> Map.keys()
      {:ok, headers, rows}
    rescue
      e -> {:error, Exception.message(e)}
    end
  end

  def parse_xlsx_raw(file_path) do
    try do
      {:ok, tid} = Xlsxir.multi_extract(file_path, 0)
      rows_list = Xlsxir.get_list(tid)
      Xlsxir.close(tid)

      [headers_raw | data_rows] = rows_list
      headers = Enum.map(headers_raw, &raw_header_to_string/1)

      rows =
        Enum.map(data_rows, fn row ->
          headers
          |> Enum.zip(pad_row(row, length(headers)))
          |> Map.new(fn {k, v} -> {k, v} end)
        end)

      {:ok, headers, rows}
    rescue
      e -> {:error, Exception.message(e)}
    end
  end

  defp raw_header_to_string(h) when is_binary(h), do: h
  defp raw_header_to_string(h), do: to_string(h)

  @doc """
  Guess which source column should map to each target field, based on the column name.
  Returns %{target_atom => source_column_string_or_nil}.
  """
  def guess_column_mapping(headers) when is_list(headers) do
    %{
      code:          best_header_match(headers, ~w(code product_code sku barcode gtin ean barcode_number)),
      name:          best_header_match(headers, ~w(name product_name brand brand_name title product_title)),
      description:   best_header_match(headers, ~w(description desc product_description product_desc details)),
      weight:        best_header_match(headers, ~w(weight net_weight gross_weight size quantity volume qty)),
      uom:           best_header_match(headers, ~w(uom unit unit_of_measure measure unit_of_measurement)),
      target_market: best_header_match(headers, ~w(target_market market country region territory countries))
    }
  end

  defp best_header_match(headers, keywords) do
    Enum.find(headers, fn h ->
      norm = h |> String.downcase() |> String.trim() |> String.replace(~r/[\s\-\/\.]+/, "_")
      Enum.any?(keywords, fn kw -> norm == kw or String.contains?(norm, kw) end)
    end)
  end

  @doc """
  Apply a column mapping to a list of raw rows, returning normalised product maps.
  mapping = %{code: "Column A", name: "Column B", ...}
  """
  def apply_column_mapping(raw_rows, mapping) when is_list(raw_rows) do
    raw_rows
    |> Enum.map(fn row ->
      code  = get_raw(row, mapping[:code])
      name  = get_raw(row, mapping[:name])
      desc  = get_raw(row, mapping[:description])

      if code || name || desc do
        %{
          code:           normalize_code(code),
          name:           to_string(name || ""),
          description:    to_string(desc  || ""),
          weight:         parse_number(get_raw(row, mapping[:weight])),
          uom:            normalize_uom(get_raw(row, mapping[:uom])),
          classification: nil,
          target_market:  normalize_target_market(get_raw(row, mapping[:target_market]))
        }
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp get_raw(_row, nil), do: nil
  defp get_raw(_row, ""),  do: nil
  defp get_raw(row, col) when is_binary(col), do: Map.get(row, col)

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
    |> String.replace(~r/[\s\-\/\.]+/, "_")
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

    target_market =
      get_value(raw_product, [
        :target_market, :target_markets, :market, :markets,
        :country, :countries, :region, :regions, :territory,
        "target_market", "target_markets", "market", "markets",
        "country", "countries", "region", "regions", "territory"
      ])

    # Only return if we have minimum required fields
    if code && (name || description) do
      %{
        code: normalize_code(code),
        name: to_string(name || ""),
        description: to_string(description || ""),
        weight: parse_number(weight),
        uom: normalize_uom(uom),
        classification: parse_number(classification),
        target_market: normalize_target_market(target_market)
      }
    else
      nil
    end
  end

  defp normalize_product(_), do: nil

  # Store code as string without ".0" (CSV/Excel often parse long numbers as float)
  @uom_map %{
    "gram" => "GRM", "grams" => "GRM", "g" => "GRM", "grm" => "GRM",
    "kilogram" => "KGM", "kilograms" => "KGM", "kg" => "KGM", "kgm" => "KGM",
    "millilitre" => "MLT", "milliliter" => "MLT", "ml" => "MLT", "mlt" => "MLT",
    "millilitres" => "MLT", "milliliters" => "MLT",
    "litre" => "LTR", "liter" => "LTR", "l" => "LTR", "ltr" => "LTR",
    "litres" => "LTR", "liters" => "LTR",
    "centilitre" => "CTL", "centiliter" => "CTL", "cl" => "CTL", "ctl" => "CTL",
    "metre" => "MTR", "meter" => "MTR", "mtr" => "MTR",
    "centimetre" => "CMT", "centimeter" => "CMT", "cm" => "CMT", "cmt" => "CMT",
    "millimetre" => "MMT", "millimeter" => "MMT", "mm" => "MMT", "mmt" => "MMT",
    "inch" => "INH", "inches" => "INH", "inh" => "INH",
    "pack" => "PK", "packs" => "PK", "pk" => "PK",
    "packet" => "PA", "packets" => "PA", "pa" => "PA",
    "dozen" => "DZN", "dzn" => "DZN",
    "pair" => "PR", "pairs" => "PR", "pr" => "PR",
    "page" => "ZP", "pages" => "ZP", "zp" => "ZP",
    "piece" => "H87", "pieces" => "H87", "pcs" => "H87", "pc" => "H87", "h87" => "H87",
    "tablet" => "U2", "tablets" => "U2", "tab" => "U2", "tabs" => "U2", "u2" => "U2",
    "capsule" => "AV", "capsules" => "AV", "cap" => "AV", "caps" => "AV", "av" => "AV",
    "ounce" => "ONZ", "ounces" => "ONZ", "oz" => "ONZ", "onz" => "ONZ",
    "ton" => "LTN", "tons" => "LTN", "tonne" => "LTN", "tonnes" => "LTN", "ltn" => "LTN",
    "kilowatt" => "KWT", "kwt" => "KWT", "kw" => "KWT",
    "watt" => "WTT", "watts" => "WTT", "w" => "WTT", "wtt" => "WTT",
    "volt" => "VLT", "volts" => "VLT", "v" => "VLT", "vlt" => "VLT",
    "kilovolt" => "KVT", "kilovolts" => "KVT", "kv" => "KVT", "kvt" => "KVT",
    "ampere" => "AMP", "amperes" => "AMP", "amp" => "AMP", "amps" => "AMP", "a" => "AMP"
  }

  defp normalize_uom(nil), do: ""
  defp normalize_uom(v) when is_binary(v) do
    key = v |> String.downcase() |> String.trim()
    Map.get(@uom_map, key, String.upcase(String.trim(v)))
  end
  defp normalize_uom(v), do: normalize_uom(to_string(v))

  # Maps single country names/codes; multiple countries (comma-separated etc.) → "001"
  @country_map %{
    "kenya" => "KE", "ke" => "KE",
    "uganda" => "UG", "ug" => "UG",
    "001" => "001", "global" => "001", "worldwide" => "001", "world" => "001",
    "international" => "001"
  }

  defp normalize_target_market(nil), do: "KE"
  defp normalize_target_market(v) when is_binary(v) do
    s = String.trim(v)
    if s == "", do: "KE", else: do_normalize_market(s)
  end
  defp normalize_target_market(v), do: normalize_target_market(to_string(v))

  defp do_normalize_market(s) do
    parts =
      s
      |> String.split(~r/[,\/\|&\+]/)
      |> Enum.map(&(String.downcase(String.trim(&1))))
      |> Enum.reject(&(&1 == ""))

    if length(parts) > 1 do
      "001"
    else
      Map.get(@country_map, hd(parts), String.upcase(s))
    end
  end

  defp normalize_code(nil), do: ""
  defp normalize_code(v) when is_integer(v), do: to_string(v)
  defp normalize_code(v) when is_number(v) do
    if trunc(v) == v, do: to_string(trunc(v)), else: to_string(v)
  end
  defp normalize_code(v) when is_binary(v) do
    s = String.trim(v)
    if String.ends_with?(s, ".0") and String.length(s) > 2 do
      rest = String.slice(s, 0, String.length(s) - 2)
      if rest =~ ~r/^\d+$/, do: rest, else: s
    else
      s
    end
  end
  defp normalize_code(v), do: to_string(v)

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
