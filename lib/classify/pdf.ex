defmodule Classify.PDF.ProductClassificationReport do
  @moduledoc """
  Generates PDF reports for classified products using PdfGenerator or similar library.
  """

  @doc """
  Generate a PDF report of classified products.
  Returns {:ok, filepath} or {:error, reason}
  """
  def generate(products, options \\ []) do
    html = render_html(products, options)
    filename = "product_classification_#{DateTime.utc_now() |> DateTime.to_unix()}.pdf"
    output_path = Path.join(System.tmp_dir(), filename)

    # Generate PDF from HTML
    # Using PdfGenerator.generate/2 or similar
    case PdfGenerator.generate(html,
           page_size: "A4",
           shell_params: ["--orientation", "Landscape"]
         ) do
      {:ok, pdf_path} ->
        File.cp!(pdf_path, output_path)
        {:ok, output_path}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp render_html(products, _options) do
    """
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <style>
        body {
          font-family: Arial, sans-serif;
          margin: 20px;
        }
        h1 {
          color: #1f2937;
          border-bottom: 3px solid #3b82f6;
          padding-bottom: 10px;
        }
        .header {
          margin-bottom: 30px;
        }
        .summary {
          display: flex;
          gap: 20px;
          margin-bottom: 30px;
        }
        .summary-card {
          flex: 1;
          padding: 15px;
          border-radius: 8px;
          border: 1px solid #e5e7eb;
        }
        .summary-card h3 {
          margin: 0 0 5px 0;
          font-size: 14px;
          color: #6b7280;
        }
        .summary-card .value {
          font-size: 32px;
          font-weight: bold;
          color: #1f2937;
        }
        table {
          width: 100%;
          border-collapse: collapse;
          margin-top: 20px;
        }
        th {
          background-color: #f3f4f6;
          color: #374151;
          font-weight: 600;
          text-align: left;
          padding: 12px;
          border-bottom: 2px solid #e5e7eb;
        }
        td {
          padding: 12px;
          border-bottom: 1px solid #e5e7eb;
        }
        tr:hover {
          background-color: #f9fafb;
        }
        .confidence-badge {
          display: inline-block;
          padding: 4px 12px;
          border-radius: 12px;
          font-size: 12px;
          font-weight: 600;
        }
        .confidence-high {
          background-color: #d1fae5;
          color: #065f46;
        }
        .confidence-medium {
          background-color: #fef3c7;
          color: #92400e;
        }
        .confidence-low {
          background-color: #fee2e2;
          color: #991b1b;
        }
        .footer {
          margin-top: 40px;
          padding-top: 20px;
          border-top: 1px solid #e5e7eb;
          text-align: center;
          color: #6b7280;
          font-size: 12px;
        }
      </style>
    </head>
    <body>
      <div class="header">
        <h1>Product Classification Report</h1>
        <p>Generated: #{format_datetime(DateTime.utc_now())}</p>
      </div>

      <div class="summary">
        <div class="summary-card">
          <h3>Total Products</h3>
          <div class="value">#{length(products)}</div>
        </div>
        <div class="summary-card">
          <h3>Classified</h3>
          <div class="value">#{count_classified(products)}</div>
        </div>
        <div class="summary-card">
          <h3>Needs Review</h3>
          <div class="value">#{count_needs_review(products)}</div>
        </div>
        <div class="summary-card">
          <h3>Avg Confidence</h3>
          <div class="value">#{format_percentage(average_confidence(products))}</div>
        </div>
      </div>

      <table>
        <thead>
          <tr>
            <th>Product Code</th>
            <th>Name</th>
            <th>Description</th>
            <th>Brick Code</th>
            <th>Classification</th>
            <th>Confidence</th>
            <th>Target Market</th>
          </tr>
        </thead>
        <tbody>
          #{render_product_rows(products)}
        </tbody>
      </table>

      <div class="footer">
        <p>This report contains #{length(products)} classified products.</p>
        <p>© #{DateTime.utc_now().year} Product Classification System</p>
      </div>
    </body>
    </html>
    """
  end

  defp render_product_rows(products) do
    products
    |> Enum.map(&render_product_row/1)
    |> Enum.join("\n")
  end

  defp render_product_row(product) do
    classification =
      product.suggested_classification ||
        %{confidence: 0, brick: "N/A", description: "Unclassified"}

    confidence_class = confidence_class(classification.confidence)

    """
    <tr>
      <td>#{escape_html(product.code)}</td>
      <td>#{escape_html(product.name)}</td>
      <td>#{escape_html(product.description)}</td>
      <td>#{escape_html(classification.brick)}</td>
      <td>#{escape_html(classification.description)}</td>
      <td>
        <span class="confidence-badge confidence-#{confidence_class}">
          #{format_confidence(classification.confidence)}
        </span>
      </td>
      <td>#{escape_html(Map.get(product, :target_market, "N/A"))}</td>
    </tr>
    """
  end

  defp confidence_class(confidence) when confidence >= 0.9, do: "high"
  defp confidence_class(confidence) when confidence >= 0.7, do: "medium"
  defp confidence_class(_), do: "low"

  defp format_confidence(confidence) when is_float(confidence) do
    "#{Float.round(confidence * 100, 1)}%"
  end

  defp format_confidence(_), do: "N/A"

  defp format_percentage(value) when is_float(value) do
    "#{Float.round(value * 100, 0)}%"
  end

  defp format_percentage(_), do: "N/A"

  defp count_classified(products) do
    Enum.count(products, fn p ->
      case Map.get(p, :suggested_classification) do
        %{brick: brick} when brick != "00000000" -> true
        _ -> false
      end
    end)
  end

  defp count_needs_review(products) do
    Enum.count(products, fn p ->
      case Map.get(p, :suggested_classification) do
        %{confidence: confidence} when confidence < 0.7 -> true
        _ -> false
      end
    end)
  end

  defp average_confidence(products) do
    confidences =
      products
      |> Enum.map(fn p ->
        case Map.get(p, :suggested_classification) do
          %{confidence: confidence} -> confidence
          _ -> 0.0
        end
      end)

    if length(confidences) > 0 do
      Enum.sum(confidences) / length(confidences)
    else
      0.0
    end
  end

  defp format_datetime(datetime) do
    Calendar.strftime(datetime, "%B %d, %Y at %I:%M %p UTC")
  end

  defp escape_html(nil), do: ""

  defp escape_html(value) when is_binary(value) do
    value
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
  end

  defp escape_html(value), do: to_string(value)
end
