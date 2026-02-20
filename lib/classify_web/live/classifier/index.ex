defmodule ClassifyWeb.ClassifierLive.Index do
  use ClassifyWeb, :live_view
  alias Classify.Classifier
  alias Classify.Classifications
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
     |> assign(:classification_descriptions, %{})
     |> assign(:classification_suggestions, %{})
     |> assign(:duplicate_indices, MapSet.new())
     |> assign(:invalid_gtin_indices, MapSet.new())
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
        dest = Path.join(System.tmp_dir!(), "#{entry.uuid}-#{entry.client_name}")
        File.cp!(path, dest)
        {:ok, dest}
      end)

    case uploaded_files do
      [file_path] ->
        case parse_file(file_path) do
          {:ok, products} ->
            {:noreply,
             socket
             |> assign(:step, :review)
             |> assign(:products, products)
             |> assign(:uploaded_file, file_path)
             |> assign(:error, nil)}

          {:error, reason} ->
            {:noreply, assign(socket, :error, "Failed to parse file: #{reason}")}
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

    case generate_pdf(socket.assigns.classified_products) do
      {:ok, pdf_path} ->
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
     |> assign(:classification_descriptions, classification_descriptions_from_products(reviewed))
     |> assign(:duplicate_indices, duplicate_indices(reviewed))
     |> assign(:invalid_gtin_indices, invalid_gtin_indices(reviewed))}
  end

  @impl true
  def handle_event("export_csv", _params, socket) do
    products = socket.assigns.reviewed_products
    csv_content = build_csv(products)

    {:noreply,
     push_event(socket, "trigger_download", %{
       content: Base.encode64(csv_content),
       filename: "products.csv",
       content_type: "text/csv"
     })}
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
     |> assign(:classification_descriptions, %{})
     |> assign(:classification_suggestions, %{})
     |> assign(:duplicate_indices, MapSet.new())
     |> assign(:invalid_gtin_indices, MapSet.new())
     |> assign(:analysis_progress, nil)
     |> assign(:error, nil)}
  end

  @impl true

  def handle_event("suggest_similar_classes", %{"index" => idx_str}, socket) do
    idx = parse_index(idx_str)

    if idx == nil or idx < 0 or idx >= length(socket.assigns.reviewed_products) do
      {:noreply, socket}
    else
      product = Enum.at(socket.assigns.reviewed_products, idx)

      suggestions = Classifications.suggest_for_product(product, 10)

      # Always pin current brick at top so user can see what's selected
      current_brick =
        (product.classification || product[:classification]) |> to_string() |> String.trim()

      suggestions =
        if current_brick != "" do
          current_item =
            case Classifications.get_by_brick(current_brick) do
              nil ->
                %{brick: current_brick, description: "—", class_title: "", segment_title: ""}

              c ->
                %{
                  brick: c.brick,
                  description: c.description || "",
                  class_title: c[:class_title] || "",
                  segment_title: c[:segment_title] || ""
                }
            end

          [current_item | Enum.reject(suggestions, &(&1.brick == current_brick))]
        else
          suggestions
        end

      suggestions_map =
        Map.put(socket.assigns.classification_suggestions || %{}, idx, suggestions)

      {:noreply, assign(socket, :classification_suggestions, suggestions_map)}
    end
  end

  @impl true
  def handle_event("clear_similar_suggestions", %{"index" => idx_str}, socket) do
    idx = parse_index(idx_str)

    suggestions_map =
      if idx != nil,
        do: Map.delete(socket.assigns.classification_suggestions || %{}, idx),
        else: socket.assigns.classification_suggestions || %{}

    {:noreply, assign(socket, :classification_suggestions, suggestions_map)}
  end

  @impl true
  def handle_event("apply_suggestion", %{"index" => idx_str, "brick" => brick}, socket) do
    idx = parse_index(idx_str)

    if idx == nil or idx < 0 or idx >= length(socket.assigns.reviewed_products) or brick == "" do
      {:noreply, socket}
    else
      updated =
        List.update_at(socket.assigns.reviewed_products, idx, fn p ->
          prev = p.classification || p[:classification]

          p
          |> Map.put(:classification, String.trim(brick))
          |> Map.put(:previous_classification, prev)
        end)

      suggestions_map = Map.delete(socket.assigns.classification_suggestions || %{}, idx)

      {:noreply,
       socket
       |> assign(:reviewed_products, updated)
       |> assign(:cleaned_products, updated)
       |> assign(:classification_descriptions, classification_descriptions_from_products(updated))
       |> assign(:classification_suggestions, suggestions_map)
       |> assign(:duplicate_indices, duplicate_indices(updated))
       |> assign(:invalid_gtin_indices, invalid_gtin_indices(updated))}
    end
  end

  @impl true
  def handle_event("update_reviewed_product", params, socket) do
    case parse_update_reviewed_params(params) do
      {index, key, value} ->
        updated =
          List.update_at(socket.assigns.reviewed_products, index, fn p ->
            value_parsed = parse_reviewed_value(key, value)
            p = Map.put(p, key, value_parsed)

            if key == :description,
              do: Map.put(p, :description, sentence_case(p.description || "")),
              else: p
          end)

        {:noreply,
         socket
         |> assign(:reviewed_products, updated)
         |> assign(:cleaned_products, updated)
         |> assign(
           :classification_descriptions,
           classification_descriptions_from_products(updated)
         )
         |> assign(:duplicate_indices, duplicate_indices(updated))
         |> assign(:invalid_gtin_indices, invalid_gtin_indices(updated))}

      nil ->
        # Unknown payload shape (e.g. value => %{"value" => _} with no index:field)
        {:noreply, socket}
    end
  end

  defp parse_update_reviewed_params(params) do
    # Skip LiveView/internal keys
    payload =
      params
      |> Enum.reject(fn {k, _} ->
        k in ["event", "type"] or String.starts_with?(to_string(k), "_")
      end)
      |> Enum.into(%{})

    # Prefer explicit index and field (e.g. from phx-value-*)
    index_raw = payload["index"]
    field_name = payload["field"]

    if index_raw != nil and field_name != nil do
      key = String.to_existing_atom(field_name)
      value = payload[field_name] || flatten_value(payload["value"])
      index = parse_index(index_raw)
      if index != nil, do: {index, key, value || ""}, else: nil
    else
      # Find "index:field" key (our input names)
      payload
      |> Enum.find_value(fn
        {name, value} when is_binary(name) ->
          if String.contains?(name, ":") do
            parts = String.split(name, ":", parts: 2)

            if length(parts) == 2 do
              [idx_str, field_str] = parts
              index = parse_index(idx_str)
              key = String.to_existing_atom(field_str)
              if index != nil, do: {index, key, value}, else: nil
            end
          end

        _ ->
          nil
      end)
      |> case do
        {index, key, value} ->
          {index, key, value}

        _ ->
          # Nested value: params["value"] => %{"1:description" => "..."} or %{"value" => "..."}
          inner = payload["value"]

          if is_map(inner) do
            Enum.find_value(inner, fn
              {k, v} when is_binary(k) ->
                if String.contains?(k, ":") do
                  [idx_str, field_str] = String.split(k, ":", parts: 2)
                  index = parse_index(idx_str)
                  key = String.to_existing_atom(field_str)
                  if index != nil, do: {index, key, v}, else: nil
                end

              _ ->
                nil
            end)
          end
      end
    end
  end

  defp parse_index(str) when is_binary(str) do
    case Integer.parse(str) do
      {n, ""} -> n
      _ -> nil
    end
  end

  defp parse_index(n) when is_integer(n), do: n
  defp parse_index(_), do: nil

  # phx-blur sometimes sends value as %{"value" => "actual"}
  defp flatten_value(%{"value" => v}), do: v
  defp flatten_value(v) when is_binary(v), do: v
  defp flatten_value(_), do: nil

  @impl true
  def handle_info({:analysis_progress, current, total}, socket) do
    {:noreply, assign(socket, :analysis_progress, "Batch #{current} of #{total}")}
  end

  @impl true
  def handle_info({:analysis_done, reviewed}, socket) do
    products = socket.assigns.products

    reviewed_with_original =
      Enum.zip(products, reviewed)
      |> Enum.map(fn {orig, rev} -> Map.put(rev, :original, orig) end)

    {:noreply,
     socket
     |> assign(:step, :analysed)
     |> assign(:reviewed_products, reviewed_with_original)
     |> assign(:cleaned_products, reviewed_with_original)
     |> assign(:classification_descriptions, classification_descriptions_from_products(reviewed))
     |> assign(:duplicate_indices, duplicate_indices(reviewed))
     |> assign(:invalid_gtin_indices, invalid_gtin_indices(reviewed))
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
            <% total_rows = length(@reviewed_products)

            error_count =
              count_reviewed_errors(@duplicate_indices, @invalid_gtin_indices || MapSet.new())

            no_class_count = count_no_classification(@reviewed_products)
            valid_count = total_rows - error_count %>
            <div class="space-y-5">
              
              <div class="grid grid-cols-2 sm:grid-cols-4 gap-3">
                <div class="bg-white rounded-xl border border-gray-200 px-4 py-3">
                  <p class="text-2xl font-semibold text-gray-900">{total_rows}</p>
                  <p class="text-xs text-gray-400 mt-0.5 uppercase tracking-wide">Total rows</p>
                </div>
                <div class="bg-white rounded-xl border border-gray-200 px-4 py-3">
                  <p class="text-2xl font-semibold text-emerald-600">{valid_count}</p>
                  <p class="text-xs text-gray-400 mt-0.5 uppercase tracking-wide">Valid</p>
                </div>
                <div class={"rounded-xl border px-4 py-3 " <> if(error_count > 0, do: "bg-red-50 border-red-200", else: "bg-white border-gray-200")}>
                  <p class={"text-2xl font-semibold " <> if(error_count > 0, do: "text-red-600", else: "text-gray-900")}>
                    {error_count}
                  </p>
                  <p class="text-xs text-gray-400 mt-0.5 uppercase tracking-wide">Errors</p>
                </div>
                <div class={"rounded-xl border px-4 py-3 " <> if(no_class_count > 0, do: "bg-amber-50 border-amber-200", else: "bg-white border-gray-200")}>
                  <p class={"text-2xl font-semibold " <> if(no_class_count > 0, do: "text-amber-600", else: "text-gray-900")}>
                    {no_class_count}
                  </p>
                  <p class="text-xs text-gray-400 mt-0.5 uppercase tracking-wide">No class.</p>
                </div>
              </div>

              <div class="bg-white rounded-xl border border-gray-200 overflow-hidden">
                <div class="px-5 py-3.5 border-b border-gray-100 flex items-center justify-between">
                  <div>
                    <h3 class="text-sm font-semibold text-gray-800">AI Reviewed — Editable</h3>
                    <p class="text-xs text-gray-400 mt-0.5">
                      Grey rows = original data. Edit any field and click away to save.
                      <span class="text-red-500">Red rows</span>
                      = duplicate codes or invalid EAN-13 GTIN.
                    </p>
                  </div>
                </div>

                <div class="overflow-x-auto">
                  <table class="min-w-full">
                    <thead>
                      <tr class="border-b border-gray-200 bg-gray-50">
                        <th class="px-3 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                          Code
                        </th>
                        <th class="px-3 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                          Name
                        </th>
                        <th class="px-3 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                          Description
                        </th>
                        <th class="px-3 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                          Weight
                        </th>
                        <th class="px-3 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                          UOM
                        </th>
                        <th class="px-3 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                          Class.
                        </th>
                        <th class="px-3 py-3 text-left text-xs font-semibold text-gray-500 uppercase tracking-wider">
                          Market
                        </th>
                        <th class="px-3 py-3 w-16"></th>
                      </tr>
                    </thead>
                    <tbody>
                      <%= for {p, idx} <- Enum.with_index(@reviewed_products) do %>
                        <% orig = Map.get(p, :original) %>
                        <% is_dup = MapSet.member?(@duplicate_indices, idx) %>
                        <% is_invalid_gtin =
                          MapSet.member?(@invalid_gtin_indices || MapSet.new(), idx) %>
                        <% has_error = is_dup or is_invalid_gtin %>
                        <%= if orig do %>
                          <tr class={"bg-gray-50 " <> if(has_error, do: "border-l-4 border-red-300", else: "border-l-4 border-transparent")}>
                            <td class="px-3 py-1.5 text-xs text-gray-500 font-mono">
                              {format_cell(orig[:code])}
                            </td>
                            <td class="px-3 py-1.5 text-xs text-gray-500">
                              {format_cell(orig[:name])}
                            </td>
                            <td
                              class="px-3 py-1.5 text-xs text-gray-500 max-w-[18rem] truncate"
                              title={format_cell(orig[:description])}
                            >
                              {format_cell(orig[:description])}
                            </td>
                            <td class="px-3 py-1.5 text-xs text-gray-500">
                              {format_cell(orig[:weight])}
                            </td>
                            <td class="px-3 py-1.5 text-xs text-gray-500">
                              {format_cell(orig[:uom])}
                            </td>
                            <td class="px-3 py-1.5 text-xs text-gray-500 font-mono">
                              {format_cell(orig[:classification])}
                            </td>
                            <td class="px-3 py-1.5 text-xs text-gray-500">
                              {format_cell(orig[:target_market])}
                            </td>
                            <td class="px-3 py-1.5"></td>
                          </tr>
                        <% end %>
                        <tr
                          class={"border-b border-gray-100 " <> if(has_error, do: "bg-red-50 border-l-4 border-red-400", else: "bg-white border-l-4 border-transparent")}
                          title={
                            cond do
                              is_dup and is_invalid_gtin -> "Duplicate code; not valid EAN-13 (GTIN)"
                              is_dup -> "Duplicate product code"
                              is_invalid_gtin -> "Not valid EAN-13 (GTIN)"
                              true -> nil
                            end
                          }
                        >
                          <td class="px-2 py-1.5">
                            <input
                              type="text"
                              name={"#{idx}:code"}
                              value={format_cell(p.code)}
                              phx-blur="update_reviewed_product"
                              phx-value-index={idx}
                              phx-value-field="code"
                              class={"w-32 text-sm rounded border px-2 py-1.5 font-mono focus:outline-none focus:ring-1 focus:ring-blue-400 " <> if(has_error, do: "border-red-300 bg-red-50", else: "border-gray-200 bg-white")}
                            />
                          </td>
                          <td class="px-2 py-1.5">
                            <input
                              type="text"
                              name={"#{idx}:name"}
                              value={p.name}
                              phx-blur="update_reviewed_product"
                              phx-value-index={idx}
                              phx-value-field="name"
                              class="w-full min-w-[8rem] text-sm rounded border border-gray-200 bg-white px-2 py-1.5 focus:outline-none focus:ring-1 focus:ring-blue-400"
                            />
                          </td>
                          <td class="px-2 py-1.5 align-top">
                            <textarea
                              name={"#{idx}:description"}
                              phx-blur="update_reviewed_product"
                              phx-value-index={idx}
                              phx-value-field="description"
                              rows="2"
                              class="min-w-[16rem] w-full text-sm rounded border border-gray-200 bg-white px-2 py-1.5 resize-y focus:outline-none focus:ring-1 focus:ring-blue-400"
                            >{p.description}</textarea>
                          </td>
                          <td class="px-2 py-1.5">
                            <input
                              type="text"
                              name={"#{idx}:weight"}
                              value={format_cell(p.weight)}
                              phx-blur="update_reviewed_product"
                              phx-value-index={idx}
                              phx-value-field="weight"
                              class="w-16 text-sm rounded border border-gray-200 bg-white px-2 py-1.5 focus:outline-none focus:ring-1 focus:ring-blue-400"
                            />
                          </td>
                          <td class="px-2 py-1.5">
                            <input
                              type="text"
                              name={"#{idx}:uom"}
                              value={p.uom}
                              phx-blur="update_reviewed_product"
                              phx-value-index={idx}
                              phx-value-field="uom"
                              class="w-14 text-sm rounded border border-gray-200 bg-white px-2 py-1.5 focus:outline-none focus:ring-1 focus:ring-blue-400"
                            />
                          </td>
                          <td class="px-2 py-1.5 align-top">
                            <div class="flex items-start gap-1 flex-wrap">
                              <input
                                type="text"
                                name={"#{idx}:classification"}
                                value={format_cell(p.classification)}
                                phx-blur="update_reviewed_product"
                                phx-value-index={idx}
                                phx-value-field="classification"
                                class="w-24 text-sm rounded border border-gray-200 bg-white px-2 py-1.5 font-mono focus:outline-none focus:ring-1 focus:ring-blue-400"
                              />
                              <button
                                type="button"
                                phx-click="suggest_similar_classes"
                                phx-value-index={idx}
                                class="text-xs text-blue-500 hover:text-blue-700 font-medium whitespace-nowrap mt-1"
                              >
                                Similar
                              </button>
                            </div>
                            <% desc =
                              Map.get(@classification_descriptions, format_cell(p.classification)) %>
                            <%= if is_binary(desc) && desc != "" do %>
                              <p class="mt-1 text-xs text-blue-500 italic max-w-[14rem] leading-snug">
                                {desc}
                              </p>
                            <% end %>
                            <% row_suggestions = Map.get(@classification_suggestions || %{}, idx) %>
                            <%= if row_suggestions != nil do %>
                              <div
                                id={"similar-suggestions-#{idx}"}
                                class="mt-1.5 border border-gray-200 rounded-lg shadow-sm p-2 bg-white max-h-48 overflow-y-auto z-10 relative"
                                phx-hook="ClickAway"
                                data-index={idx}
                              >
                                <p class="text-xs font-semibold text-gray-500 mb-1.5 uppercase tracking-wide">
                                  Choose a class
                                </p>
                                <%= if row_suggestions == [] do %>
                                  <p class="text-xs text-gray-400">No similar classes found.</p>
                                <% else %>
                                  <ul class="space-y-0.5">
                                    <%= for sug <- row_suggestions do %>
                                      <% is_current = format_cell(p.classification) == sug.brick %>
                                      <li>
                                        <button
                                          type="button"
                                          phx-click="apply_suggestion"
                                          phx-value-index={idx}
                                          phx-value-brick={sug.brick}
                                          class={"block w-full text-left text-xs py-1.5 px-2 rounded hover:bg-blue-50" <> if(is_current, do: " bg-blue-50 font-medium", else: "")}
                                        >
                                          <span class="font-mono text-gray-700">{sug.brick}</span>
                                          <%= if is_current do %>
                                            <span class="ml-1 text-blue-500 text-xs">current</span>
                                          <% end %>
                                          <span class="text-gray-500 ml-1">– {sug.description}</span>
                                        </button>
                                      </li>
                                    <% end %>
                                  </ul>
                                <% end %>
                              </div>
                            <% end %>
                          </td>
                          <td class="px-2 py-1">
                            <input
                              type="text"
                              name={"#{idx}:target_market"}
                              value={p.target_market}
                              phx-blur="update_reviewed_product"
                              phx-value-index={idx}
                              phx-value-field="target_market"
                              class="w-16 text-sm rounded border border-gray-200 bg-white px-2 py-1.5 focus:outline-none focus:ring-1 focus:ring-blue-400"
                            />
                          </td>
                          <td class="px-2 py-1.5">
                            <button
                              type="button"
                              phx-click="delete_reviewed_row"
                              phx-value-index={idx}
                              class="text-xs text-red-400 hover:text-red-600 font-medium px-2 py-1 rounded hover:bg-red-50"
                              title="Delete row"
                            >
                              Delete
                            </button>
                          </td>
                        </tr>
                        <tr>
                          <td colspan="8" class="p-0">
                            <div class="h-px bg-gray-200 mx-3"></div>
                          </td>
                        </tr>
                        <tr>
                          <td colspan="8" class="h-3 bg-gray-50/60"></td>
                        </tr>
                        <tr>
                          <td colspan="8" class="p-0">
                            <div class="h-px bg-gray-200 mx-3"></div>
                          </td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>

                <div class="px-5 py-3 border-t border-gray-100 flex items-center justify-between bg-gray-50 rounded-b-xl">
                  <p class="text-xs text-gray-400">
                    {length(@reviewed_products)} rows — edit any cell and blur to save
                  </p>
                  <div class="flex gap-2">
                    <button
                      phx-click="reset"
                      class="px-3 py-1.5 border border-gray-300 rounded-lg text-xs font-medium text-gray-600 hover:bg-gray-100 transition"
                    >
                      Start Over
                    </button>
                    <button
                      phx-click="export_csv"
                      class="px-3 py-1.5 bg-gray-900 text-white rounded-lg text-xs font-medium hover:bg-gray-700 transition"
                    >
                      Save as CSV
                    </button>
                  </div>
                </div>
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
                      <% orig = Map.get(product, :original) %>
                      <%= if orig do %>
                        <tr class="bg-gray-50 border-b border-gray-200">
                          <td class="px-6 py-2 text-xs text-gray-500" colspan="5">
                            <span class="font-medium text-gray-600">Original (dirty):</span>
                            Code {format_cell(orig[:code])},
                            Name {format_cell(orig[:name])},
                            Desc {format_cell(orig[:description])} —
                            Weight {format_cell(orig[:weight])}, UOM {format_cell(orig[:uom])},
                            Class {format_cell(orig[:classification])}, Market {format_cell(
                              orig[:target_market]
                            )}
                          </td>
                        </tr>
                      <% end %>
                      <tr>
                        <td class="px-6 py-4 text-sm">
                          <div class="font-medium text-gray-900">{product.name}</div>
                          <div class="text-gray-500">{product.description}</div>
                        </td>
                        <td class="px-6 py-4 text-sm text-gray-900">
                          <div class="font-medium">{product.suggested_classification.brick}</div>
                          <%= if product.suggested_classification.description && product.suggested_classification.description != "" do %>
                            <div class="text-xs text-blue-600 italic mt-0.5 max-w-xs">
                              {product.suggested_classification.description}
                            </div>
                          <% end %>
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
  defp format_cell(v) when is_binary(v), do: strip_float_suffix(v)

  defp format_cell(v) when is_number(v) do
    if is_integer(v) or trunc(v) == v, do: to_string(trunc(v)), else: to_string(v)
  end

  defp format_cell(v), do: to_string(v) |> strip_float_suffix()

  # Avoid displaying "6164003345002.0" for codes/IDs that were parsed as float
  defp strip_float_suffix(s) when is_binary(s) do
    s = String.trim(s)

    if String.ends_with?(s, ".0") and String.length(s) > 2 do
      rest = String.slice(s, 0, String.length(s) - 2)
      if rest =~ ~r/^\d+$/, do: rest, else: s
    else
      s
    end
  end

  defp strip_float_suffix(_), do: ""

  defp sentence_case(nil), do: ""
  defp sentence_case(""), do: ""

  defp sentence_case(s) when is_binary(s) do
    s = String.trim(s)
    if s == "", do: "", else: String.capitalize(String.downcase(s))
  end

  defp sentence_case(v), do: sentence_case(to_string(v))

  defp classification_descriptions_from_products(products) do
    bricks =
      products
      |> Enum.map(fn p ->
        (p[:classification] || p["classification"]) |> to_string() |> String.trim()
      end)
      |> Enum.reject(&(&1 == "" or &1 == "nil"))
      |> Enum.uniq()

    Enum.reduce(bricks, %{}, fn brick, acc ->
      case Classifications.get_by_brick(brick) do
        nil -> acc
        c -> Map.put(acc, brick, Map.get(c, :description, "") || "")
      end
    end)
  end

  defp duplicate_indices(products) do
    codes =
      Enum.map(products, fn p -> to_string(p[:code] || p["code"] || "") |> String.trim() end)

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

  # EAN-13 / GTIN-13: 13 digits, last digit is check digit
  defp valid_ean13?(nil), do: false
  defp valid_ean13?(""), do: false

  defp valid_ean13?(code) when is_binary(code) do
    digits = String.replace(code, ~r/\D/, "")

    if String.length(digits) != 13 do
      false
    else
      list = String.graphemes(digits) |> Enum.map(&String.to_integer/1)
      weights = [1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3]

      sum =
        Enum.zip(Enum.take(list, 12), weights) |> Enum.map(fn {d, w} -> d * w end) |> Enum.sum()

      check = rem(10 - rem(sum, 10), 10)
      Enum.at(list, 12) == check
    end
  end

  defp valid_ean13?(_), do: false

  defp invalid_gtin_indices(products) do
    products
    |> Enum.with_index()
    |> Enum.reject(fn {p, _idx} ->
      raw = p[:code] || p["code"]
      code = raw |> to_string() |> String.trim()
      valid_ean13?(code)
    end)
    |> Enum.map(fn {_, idx} -> idx end)
    |> MapSet.new()
  end

  defp parse_reviewed_value(:weight, ""), do: nil

  defp parse_reviewed_value(:weight, v) when is_binary(v) do
    case Float.parse(String.trim(v)) do
      {n, _} -> n
      :error -> nil
    end
  end

  defp parse_reviewed_value(:code, v) when is_binary(v) do
    v |> String.trim() |> strip_float_suffix()
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
        [
          format_cell(p.code),
          p.name,
          p.description,
          format_cell(p.weight),
          p.uom,
          format_cell(p.classification),
          p.target_market
        ]
      end)

    [headers | rows]
    |> CSV.encode()
    |> Enum.into("")
  end

  defp parse_file(path) do
    FileParser.parse_file(path)
  end

  defp generate_pdf(_products) do
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

  defp count_no_classification(products) do
    Enum.count(products, fn p ->
      val = p[:classification] || p["classification"]
      is_nil(val) or (is_binary(val) and String.trim(val) == "")
    end)
  end

  defp count_reviewed_errors(dup_set, gtin_set) do
    MapSet.union(dup_set, gtin_set) |> MapSet.size()
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
