defmodule ClassifyWeb.ClassifierLive.Index do
  use ClassifyWeb, :live_view
  alias Classify.Classifier
  alias Classify.FileParser
  alias Classify.ProductCleaner

  @batch_size 15

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:step, :upload)
     |> assign(:uploaded_file, nil)
     |> assign(:products, [])
     |> assign(:cleaned_products, [])
     |> assign(:reviewed_products, [])
     |> assign(:classified_products, [])
     |> assign(:duplicate_indices, MapSet.new())
     |> assign(:processing, false)
     |> assign(:analysis_progress, nil)
     |> assign(:error, nil)
     |> allow_upload(:product_csv,
       accept: ~w(.csv .xlsx),
       max_entries: 1,
       max_file_size: 10_000_000
     )}
  end

  @impl true
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("upload", _params, socket) do
    uploaded_files =
      consume_uploaded_entries(socket, :product_csv, fn %{path: path}, entry ->
        # Copy file to a temp location for processing
        dest = Path.join(System.tmp_dir!(), "#{entry.uuid}-#{entry.client_name}")
        File.cp!(path, dest)
        {:ok, dest}
      end)

    case uploaded_files do
      [file_path] ->
        # Parse the uploaded file
        case parse_file(file_path) do
          {:ok, products} ->
            {:noreply,
             socket
             |> assign(:step, :review)
             |> assign(:products, products)
             |> assign(:uploaded_file, file_path)
             |> assign(:error, nil)}

          {:error, reason} ->
            {:noreply,
             socket
             |> assign(:error, "Failed to parse file: #{reason}")}
        end

      [] ->
        {:noreply, assign(socket, :error, "No file uploaded")}
    end
  end

  @impl true
  def handle_event("analyse_with_openai", _params, socket) do
    socket =
      socket
      |> assign(:processing, true)
      |> assign(:analysis_progress, "Preparing…")

    pid = self()
    products = socket.assigns.products
    batch_size = @batch_size
    batches = Enum.chunk_every(products, batch_size)
    total = length(batches)

    Task.start(fn ->
      all_reviewed =
        batches
        |> Enum.with_index(1)
        |> Enum.flat_map(fn {batch, idx} ->
          send(pid, {:analysis_progress, idx, total})
          ProductCleaner.analyse_batch(batch)
        end)

      send(pid, {:analysis_done, all_reviewed})
    end)

    {:noreply, socket}
  end

  @impl true
  def handle_event("update_classification", %{"index" => index, "brick" => brick}, socket) do
    index = String.to_integer(index)

    updated_products =
      List.update_at(socket.assigns.classified_products, index, fn product ->
        classification = Classifier.get_classification_by_brick(brick)
        Map.put(product, :suggested_classification, classification)
      end)

    {:noreply, assign(socket, :classified_products, updated_products)}
  end

  @impl true
  def handle_event("export_pdf", _params, socket) do
    socket = assign(socket, :processing, true)

    # Generate PDF
    case generate_pdf(socket.assigns.classified_products) do
      {:ok, pdf_path} ->
        # Trigger download
        {:noreply,
         socket
         |> push_event("trigger_download", %{url: "/downloads/#{Path.basename(pdf_path)}"})
         |> assign(:processing, false)
         |> put_flash(:info, "PDF generated successfully!")}

      {:error, reason} ->
        {:noreply,
         socket
         |> assign(:processing, false)
         |> assign(:error, "Failed to generate PDF: #{reason}")}
    end
  end

  @impl true
  def handle_event("delete_reviewed_row", %{"index" => idx}, socket) do
    index = String.to_integer(idx)
    reviewed = List.delete_at(socket.assigns.reviewed_products, index)
    {:noreply,
     socket
     |> assign(:reviewed_products, reviewed)
     |> assign(:cleaned_products, reviewed)
     |> assign(:duplicate_indices, duplicate_indices(reviewed))}
  end

  @impl true
  def handle_event("export_csv", _params, socket) do
    products = socket.assigns.reviewed_products
    csv_content = build_csv(products)
    {:noreply, push_event(socket, "trigger_download", %{content: Base.encode64(csv_content), filename: "products.csv", content_type: "text/csv"})}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply,
     socket
     |> assign(:step, :upload)
     |> assign(:uploaded_file, nil)
     |> assign(:products, [])
     |> assign(:cleaned_products, [])
     |> assign(:reviewed_products, [])
     |> assign(:classified_products, [])
     |> assign(:duplicate_indices, MapSet.new())
     |> assign(:analysis_progress, nil)
     |> assign(:error, nil)}
  end

  @impl true
  def handle_event("update_reviewed_product", params, socket) do
    idx = params["index"]
    field = params["field"]
    value = params[field] || params["value"] || ""
    index = String.to_integer(idx)
    key = String.to_existing_atom(field)
    updated =
      List.update_at(socket.assigns.reviewed_products, index, fn p ->
        value_parsed = parse_reviewed_value(key, value)
        p = Map.put(p, key, value_parsed)
        if key == :description, do: Map.put(p, :description, sentence_case(p.description || "")), else: p
      end)
    {:noreply,
     socket
     |> assign(:reviewed_products, updated)
     |> assign(:cleaned_products, updated)
     |> assign(:duplicate_indices, duplicate_indices(updated))}
  end

  @impl true
  def handle_info({:analysis_progress, current, total}, socket) do
    {:noreply,
     assign(socket, :analysis_progress, "Batch #{current} of #{total}")}
  end

  @impl true
  def handle_info({:analysis_done, reviewed}, socket) do
    {:noreply,
     socket
     |> assign(:step, :analysed)
     |> assign(:reviewed_products, reviewed)
     |> assign(:cleaned_products, reviewed)
     |> assign(:duplicate_indices, duplicate_indices(reviewed))
     |> assign(:processing, false)
     |> assign(:analysis_progress, nil)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-8">
        <h1 class="text-3xl font-bold text-gray-900">Product Classification System</h1>
        <p class="mt-2 text-gray-600">Upload, clean, classify, and export your product data</p>
      </div>
      
    <!-- Progress Steps -->
      <div class="mb-8">
        <nav aria-label="Progress">
          <ol class="flex items-center">
            <%= for {step_name, step_label, idx} <- [
              {:upload, "Step 1: Upload", 1},
              {:review, "Step 2: Review", 2},
              {:analysed, "Step 3: Analyse", 3}
            ] do %>
              <li class={"flex items-center " <> if(idx < 3, do: "flex-1", else: "")}>
                <div class="flex items-center">
                  <div class={get_step_class(@step, step_name, idx)}>
                    <%= if step_complete?(@step, step_name) do %>
                      <svg class="w-5 h-5 text-white" fill="currentColor" viewBox="0 0 20 20">
                        <path
                          fill-rule="evenodd"
                          d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                          clip-rule="evenodd"
                        />
                      </svg>
                    <% else %>
                      {idx}
                    <% end %>
                  </div>
                  <span class="ml-2 text-sm font-medium text-gray-900">{step_label}</span>
                </div>
                <%= if idx < 3 do %>
                  <div class="flex-1 h-0.5 mx-4 bg-gray-200"></div>
                <% end %>
              </li>
            <% end %>
          </ol>
        </nav>
      </div>

      <%= if @error do %>
        <div class="mb-4 bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {@error}
        </div>
      <% end %>
      
    <!-- Step Content -->
      <div class="bg-white shadow rounded-lg p-6">
        <%= case @step do %>
          <% :upload -> %>
            <div class="text-center">
              <svg
                class="mx-auto h-12 w-12 text-gray-400"
                stroke="currentColor"
                fill="none"
                viewBox="0 0 48 48"
              >
                <path
                  d="M28 8H12a4 4 0 00-4 4v20m32-12v8m0 0v8a4 4 0 01-4 4H12a4 4 0 01-4-4v-4m32-4l-3.172-3.172a4 4 0 00-5.656 0L28 28M8 32l9.172-9.172a4 4 0 015.656 0L28 28m0 0l4 4m4-24h8m-4-4v8m-12 4h.02"
                  stroke-width="2"
                  stroke-linecap="round"
                  stroke-linejoin="round"
                />
              </svg>
              <h3 class="mt-2 text-sm font-medium text-gray-900">Upload Product Data</h3>
              <p class="mt-1 text-sm text-gray-500">
                CSV or Excel file containing product information
              </p>

              <form phx-submit="upload" phx-change="validate" class="mt-6">
                <div class="flex justify-center px-6 pt-5 pb-6 border-2 border-gray-300 border-dashed rounded-md">
                  <div class="space-y-1 text-center">
                    <div phx-drop-target={@uploads.product_csv.ref}>
                      <label for={@uploads.product_csv.ref} class="cursor-pointer">
                        <span class="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700">
                          Select File
                        </span>
                        <.live_file_input upload={@uploads.product_csv} class="sr-only" />
                      </label>
                    </div>

                    <%= for entry <- @uploads.product_csv.entries do %>
                      <div class="mt-2 text-sm text-gray-600">
                        {entry.client_name} ({format_bytes(entry.client_size)})
                      </div>
                    <% end %>
                  </div>
                </div>

                <%= if @uploads.product_csv.entries != [] do %>
                  <button
                    type="submit"
                    class="mt-4 w-full inline-flex justify-center items-center px-4 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-blue-600 hover:bg-blue-700"
                  >
                    Upload & Process
                  </button>
                <% end %>
              </form>
            </div>
          <% :review -> %>
            <div>
              <h3 class="text-lg font-medium text-gray-900 mb-4">Review Uploaded Data</h3>
              <p class="text-sm text-gray-600 mb-4">Found {length(@products)} products</p>

              <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                  <thead class="bg-gray-50">
                    <tr>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Code
                      </th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Name
                      </th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Description
                      </th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Current Class.
                      </th>
                    </tr>
                  </thead>
                  <tbody class="bg-white divide-y divide-gray-200">
                    <%= for product <- Enum.take(@products, 10) do %>
                      <tr>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {product.code}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {product.name}
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-900">{product.description}</td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {product.classification || "N/A"}
                        </td>
                      </tr>
                    <% end %>
                  </tbody>
                </table>
                <%= if length(@products) > 10 do %>
                  <p class="mt-2 text-sm text-gray-500">
                    Showing first 10 of {length(@products)} products
                  </p>
                <% end %>
              </div>

              <div class="mt-6 flex justify-end space-x-3">
                <button
                  phx-click="reset"
                  class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                  Cancel
                </button>
                <button
                  phx-click="analyse_with_openai"
                  disabled={@processing}
                  class="px-4 py-2 bg-blue-600 text-white rounded-md text-sm font-medium hover:bg-blue-700 disabled:opacity-50"
                >
                  {if @processing, do: @analysis_progress || "Analysing…", else: "Analyse with OpenAI"}
                </button>
              </div>
            </div>
          <% :analysed -> %>
            <div>
              <h3 class="text-lg font-medium text-gray-900 mb-4">Original vs AI reviewed</h3>
                <p class="text-sm text-gray-600 mb-4">
                Compare original data with AI-reviewed rows. Edit any cell in the AI reviewed table, then save as CSV. target_market defaults to KE. Rows with duplicate product codes are highlighted in red.
              </p>

              <div class="mb-6">
                <h4 class="text-sm font-medium text-gray-700 mb-2">Original (sample)</h4>
                <div class="overflow-x-auto border border-gray-200 rounded-md">
                  <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-gray-50">
                      <tr>
                        <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
                        <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                        <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
                        <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">Weight</th>
                        <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">UOM</th>
                        <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">Class.</th>
                        <th class="px-3 py-2 text-left text-xs font-medium text-gray-500 uppercase">Market</th>
                      </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                      <%= for p <- Enum.take(@products, 10) do %>
                        <tr>
                          <td class="px-3 py-2 text-sm text-gray-900">{p.code}</td>
                          <td class="px-3 py-2 text-sm text-gray-900">{p.name}</td>
                          <td class="px-3 py-2 text-sm text-gray-500">{p.description}</td>
                          <td class="px-3 py-2 text-sm text-gray-500">{p.weight || "—"}</td>
                          <td class="px-3 py-2 text-sm text-gray-500">{p.uom || "—"}</td>
                          <td class="px-3 py-2 text-sm text-gray-500">{p.classification || "—"}</td>
                          <td class="px-3 py-2 text-sm text-gray-500">{p.target_market || "—"}</td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>
              </div>

              <div class="mb-6">
                <h4 class="text-sm font-medium text-blue-700 mb-2">AI reviewed (editable)</h4>
                <div class="overflow-x-auto border border-blue-200 rounded-md">
                  <table class="min-w-full divide-y divide-gray-200">
                    <thead class="bg-blue-50">
                      <tr>
                        <th class="px-2 py-2 text-left text-xs font-medium text-gray-500 uppercase">Code</th>
                        <th class="px-2 py-2 text-left text-xs font-medium text-gray-500 uppercase">Name</th>
                        <th class="px-2 py-2 text-left text-xs font-medium text-gray-500 uppercase">Description</th>
                        <th class="px-2 py-2 text-left text-xs font-medium text-gray-500 uppercase">Weight</th>
                        <th class="px-2 py-2 text-left text-xs font-medium text-gray-500 uppercase">UOM</th>
                        <th class="px-2 py-2 text-left text-xs font-medium text-gray-500 uppercase">Class.</th>
                        <th class="px-2 py-2 text-left text-xs font-medium text-gray-500 uppercase">Market</th>
                        <th class="px-2 py-2 text-left text-xs font-medium text-gray-500 uppercase w-20">Delete</th>
                      </tr>
                    </thead>
                    <tbody class="bg-white divide-y divide-gray-200">
                      <%= for {p, idx} <- Enum.with_index(@reviewed_products) do %>
                        <tr class={if MapSet.member?(@duplicate_indices, idx), do: "bg-red-50 border-l-4 border-red-400", else: ""} title={if MapSet.member?(@duplicate_indices, idx), do: "Duplicate product code", else: nil}>
                          <td class="px-2 py-1">
                            <input type="text" name="code" value={p.code} phx-change="update_reviewed_product" phx-debounce="blur" phx-value-index={idx} phx-value-field="code" class="w-full text-sm border-gray-300 rounded px-2 py-1" />
                          </td>
                          <td class="px-2 py-1">
                            <input type="text" name="name" value={p.name} phx-change="update_reviewed_product" phx-debounce="blur" phx-value-index={idx} phx-value-field="name" class="w-full text-sm border-gray-300 rounded px-2 py-1" />
                          </td>
                          <td class="px-2 py-1 align-top">
                            <textarea name="description" phx-change="update_reviewed_product" phx-debounce="blur" phx-value-index={idx} phx-value-field="description" rows="2" class="min-w-[18rem] w-full text-sm border-gray-300 rounded px-2 py-1 resize-y">{p.description}</textarea>
                          </td>
                          <td class="px-2 py-1">
                            <input type="text" name="weight" value={format_cell(p.weight)} phx-change="update_reviewed_product" phx-debounce="blur" phx-value-index={idx} phx-value-field="weight" class="w-20 text-sm border-gray-300 rounded px-2 py-1" />
                          </td>
                          <td class="px-2 py-1">
                            <input type="text" name="uom" value={p.uom} phx-change="update_reviewed_product" phx-debounce="blur" phx-value-index={idx} phx-value-field="uom" class="w-16 text-sm border-gray-300 rounded px-2 py-1" />
                          </td>
                          <td class="px-2 py-1">
                            <input type="text" name="classification" value={format_cell(p.classification)} phx-change="update_reviewed_product" phx-debounce="blur" phx-value-index={idx} phx-value-field="classification" class="w-24 text-sm border-gray-300 rounded px-2 py-1" />
                          </td>
                          <td class="px-2 py-1">
                            <input type="text" name="target_market" value={p.target_market} phx-change="update_reviewed_product" phx-debounce="blur" phx-value-index={idx} phx-value-field="target_market" class="w-16 text-sm border-gray-300 rounded px-2 py-1" />
                          </td>
                          <td class="px-2 py-1">
                            <button type="button" phx-click="delete_reviewed_row" phx-value-index={idx} class="text-red-600 hover:text-red-800 text-sm font-medium" title="Delete row">
                              Delete
                            </button>
                          </td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>
                <p class="mt-1 text-xs text-gray-500">{length(@reviewed_products)} rows (edit any cell and blur to save, or delete rows)</p>
              </div>

              <div class="mt-6 flex flex-wrap justify-end gap-3">
                <button phx-click="reset" class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50">
                  Start Over
                </button>
                <button phx-click="export_csv" class="px-4 py-2 bg-green-600 text-white rounded-md text-sm font-medium hover:bg-green-700">
                  Save as CSV
                </button>
              </div>
            </div>
          <% :classified -> %>
            <div>
              <h3 class="text-lg font-medium text-gray-900 mb-4">Classification Results</h3>

              <div class="mb-4 grid grid-cols-3 gap-4">
                <div class="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <div class="text-2xl font-bold text-blue-600">{length(@classified_products)}</div>
                  <div class="text-sm text-gray-600">Total Products</div>
                </div>
                <div class="bg-green-50 border border-green-200 rounded-lg p-4">
                  <div class="text-2xl font-bold text-green-600">
                    {count_classified(@classified_products)}
                  </div>
                  <div class="text-sm text-gray-600">Classified</div>
                </div>
                <div class="bg-yellow-50 border border-yellow-200 rounded-lg p-4">
                  <div class="text-2xl font-bold text-yellow-600">
                    {count_needs_review(@classified_products)}
                  </div>
                  <div class="text-sm text-gray-600">Needs Review</div>
                </div>
              </div>

              <div class="overflow-x-auto">
                <table class="min-w-full divide-y divide-gray-200">
                  <thead class="bg-gray-50">
                    <tr>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Product
                      </th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Brick Code
                      </th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Classification
                      </th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Confidence
                      </th>
                      <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                        Action
                      </th>
                    </tr>
                  </thead>
                  <tbody class="bg-white divide-y divide-gray-200">
                    <%= for {product, idx} <- Enum.with_index(@classified_products) do %>
                      <tr>
                        <td class="px-6 py-4 text-sm">
                          <div class="font-medium text-gray-900">{product.name}</div>
                          <div class="text-gray-500">{product.description}</div>
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-900">
                          {product.suggested_classification.brick}
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-900">
                          {product.suggested_classification.description}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap">
                          {render_confidence_badge(product.suggested_classification.confidence)}
                        </td>
                        <td class="px-6 py-4 whitespace-nowrap text-sm">
                          <button
                            phx-click="edit_classification"
                            phx-value-index={idx}
                            class="text-blue-600 hover:text-blue-900"
                          >
                            Edit
                          </button>
                        </td>
                      </tr>
                    <% end %>
                  </tbody>
                </table>
              </div>

              <div class="mt-6 flex justify-end space-x-3">
                <button
                  phx-click="reset"
                  class="px-4 py-2 border border-gray-300 rounded-md text-sm font-medium text-gray-700 hover:bg-gray-50"
                >
                  Start Over
                </button>
                <button
                  phx-click="export_pdf"
                  disabled={@processing}
                  class="px-4 py-2 bg-green-600 text-white rounded-md text-sm font-medium hover:bg-green-700 disabled:opacity-50"
                >
                  {if @processing, do: "Generating...", else: "Export as PDF"}
                </button>
              </div>
            </div>
        <% end %>
      </div>
    </div>
    """
  end

  # Helper Functions

  defp format_cell(nil), do: ""
  defp format_cell(""), do: ""
  defp format_cell(v) when is_binary(v), do: v
  defp format_cell(v) when is_number(v), do: to_string(v)
  defp format_cell(v), do: to_string(v)

  defp sentence_case(nil), do: ""
  defp sentence_case(""), do: ""
  defp sentence_case(s) when is_binary(s) do
    s = String.trim(s)
    if s == "", do: "", else: String.capitalize(String.downcase(s))
  end
  defp sentence_case(v), do: sentence_case(to_string(v))

  # Returns MapSet of indices where product code appears more than once (case-sensitive, trimmed).
  defp duplicate_indices(products) do
    codes = Enum.map(products, fn p -> to_string(p[:code] || p["code"] || "") |> String.trim() end)
    code_to_indices =
      codes
      |> Enum.with_index()
      |> Enum.group_by(fn {code, _} -> code end, fn {_, idx} -> idx end)
    duplicate_indices =
      code_to_indices
      |> Enum.filter(fn {_code, indices} -> length(indices) > 1 end)
      |> Enum.flat_map(fn {_, indices} -> indices end)
    MapSet.new(duplicate_indices)
  end

  defp parse_reviewed_value(:weight, ""), do: nil
  defp parse_reviewed_value(:weight, v) when is_binary(v) do
    case Float.parse(String.trim(v)) do
      {n, _} -> n
      :error -> nil
    end
  end
  defp parse_reviewed_value(:classification, ""), do: nil
  defp parse_reviewed_value(:classification, v) when is_binary(v) do
    s = String.trim(v)
    if s == "", do: nil, else: s
  end
  defp parse_reviewed_value(_key, v) when is_binary(v), do: String.trim(v)
  defp parse_reviewed_value(_key, v), do: v

  defp build_csv(products) do
    headers = ["code", "name", "description", "weight", "uom", "classification", "target_market"]
    rows =
      Enum.map(products, fn p ->
        [p.code, p.name, p.description, format_cell(p.weight), p.uom, format_cell(p.classification), p.target_market]
      end)
    [headers | rows]
    |> CSV.encode()
    |> Enum.into("")
  end

  defp parse_file(path) do
    FileParser.parse_file(path)
  end

  defp generate_pdf(_products) do
    # Generate PDF using a library like PdfGenerator or Typst
    {:ok, "/tmp/classified_products.pdf"}
  end

  defp format_bytes(bytes) do
    cond do
      bytes >= 1_000_000 -> "#{Float.round(bytes / 1_000_000, 2)} MB"
      bytes >= 1_000 -> "#{Float.round(bytes / 1_000, 2)} KB"
      true -> "#{bytes} B"
    end
  end

  defp get_step_class(current_step, step_name, _idx) do
    base = "flex items-center justify-center w-8 h-8 rounded-full text-sm font-medium"

    cond do
      step_complete?(current_step, step_name) ->
        "#{base} bg-blue-600 text-white"

      current_step == step_name ->
        "#{base} border-2 border-blue-600 text-blue-600"

      true ->
        "#{base} border-2 border-gray-300 text-gray-500"
    end
  end

  defp step_complete?(current_step, check_step) do
    step_order = [:upload, :review, :analysed, :classified, :export]
    current_idx = Enum.find_index(step_order, &(&1 == current_step)) || 0
    check_idx = Enum.find_index(step_order, &(&1 == check_step)) || 0
    check_idx < current_idx
  end

  defp count_classified(products) do
    Enum.count(products, fn p ->
      Map.get(p, :suggested_classification) != nil
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

  defp render_confidence_badge(assigns) when is_map(assigns) do
    confidence = assigns[:confidence] || 0

    {color, label} =
      cond do
        confidence >= 0.9 -> {"green", "High"}
        confidence >= 0.7 -> {"yellow", "Medium"}
        true -> {"red", "Low"}
      end

    ~H"""
    <span class={"px-2 inline-flex text-xs leading-5 font-semibold rounded-full bg-#{color}-100 text-#{color}-800"}>
      {label}
    </span>
    """
  end

  defp render_confidence_badge(confidence) when is_float(confidence) do
    render_confidence_badge(%{confidence: confidence})
  end
end
