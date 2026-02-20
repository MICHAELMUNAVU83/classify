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
     |> assign(:original_filename, nil)
     |> assign(:products, [])
     |> assign(:cleaned_products, [])
     |> assign(:reviewed_products, [])
     |> assign(:classified_products, [])
     |> assign(:classification_descriptions, %{})
     |> assign(:classification_suggestions, %{})
     |> assign(:duplicate_indices, MapSet.new())
     |> assign(:invalid_gtin_indices, MapSet.new())
     |> assign(:gtin_errors, %{})
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
        {:ok, {dest, entry.client_name}}
      end)

    case uploaded_files do
      [{file_path, client_name}] ->
        case parse_file(file_path) do
          {:ok, products} ->
            {:noreply,
             socket
             |> assign(:step, :review)
             |> assign(:products, products)
             |> assign(:uploaded_file, file_path)
             |> assign(:original_filename, client_name)
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
     |> assign(:invalid_gtin_indices, invalid_gtin_indices(reviewed))
     |> assign(:gtin_errors, gtin_errors_map(reviewed))}
  end

  @impl true
  def handle_event("export_csv", _params, socket) do
    products = socket.assigns.reviewed_products
    csv_content = build_csv(products)

    original = socket.assigns[:original_filename] || "products"
    base = Path.basename(original, Path.extname(original))
    export_filename = "#{base}_cleaned.csv"

    {:noreply,
     push_event(socket, "trigger_download", %{
       content: Base.encode64(csv_content),
       filename: export_filename,
       content_type: "text/csv"
     })}
  end

  @impl true
  def handle_event("reset", _params, socket) do
    {:noreply,
     socket
     |> assign(:step, :upload)
     |> assign(:uploaded_file, nil)
     |> assign(:original_filename, nil)
     |> assign(:products, [])
     |> assign(:cleaned_products, [])
     |> assign(:reviewed_products, [])
     |> assign(:classified_products, [])
     |> assign(:classification_descriptions, %{})
     |> assign(:classification_suggestions, %{})
     |> assign(:duplicate_indices, MapSet.new())
     |> assign(:invalid_gtin_indices, MapSet.new())
     |> assign(:gtin_errors, %{})
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
       |> assign(:invalid_gtin_indices, invalid_gtin_indices(updated))
       |> assign(:gtin_errors, gtin_errors_map(updated))}
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
         |> assign(:invalid_gtin_indices, invalid_gtin_indices(updated))
         |> assign(:gtin_errors, gtin_errors_map(updated))}

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
     |> assign(:gtin_errors, gtin_errors_map(reviewed))
     |> assign(:processing, false)
     |> assign(:analysis_progress, nil)}
  end

  @impl true
  # ─────────────────────────────────────────────────────────────────────────────
  # GS1-branded Product Classification LiveView – render/1 only
  # Drop this render/1 into your existing LiveView module.
  # ─────────────────────────────────────────────────────────────────────────────

  def render(assigns) do
    ~H"""
    <%!-- GS1 colour tokens (injected once via a <style> tag) --%>
    <style>
      :root {
        --gs1-blue:       #003087;
        --gs1-blue-mid:   #0053A0;
        --gs1-blue-light: #0070C8;
        --gs1-orange:     #F26334;
        --gs1-orange-lt:  #FFF0EA;
        --gs1-red:        #CC0000;
        --gs1-green:      #00833E;
        --gs1-amber:      #F5A623;
        --gs1-gray-50:    #F7F8FA;
        --gs1-gray-100:   #EEF0F4;
        --gs1-gray-200:   #D8DCE6;
        --gs1-gray-400:   #8F95A3;
        --gs1-gray-700:   #3A3F4B;
        --gs1-gray-900:   #141820;
      }

      /* ── Progress bar pulse animation ─────────────────────── */
      @keyframes gs1-pulse {
        0%, 100% { opacity: 1; }
        50%       { opacity: .45; }
      }
      @keyframes gs1-slide {
        0%   { transform: translateX(-100%); }
        100% { transform: translateX(400%); }
      }
      @keyframes gs1-spin {
        to { transform: rotate(360deg); }
      }
      @keyframes gs1-check-in {
        0%   { transform: scale(0) rotate(-30deg); opacity: 0; }
        70%  { transform: scale(1.2) rotate(5deg); opacity: 1; }
        100% { transform: scale(1) rotate(0deg); opacity: 1; }
      }
      @keyframes gs1-fade-up {
        from { opacity: 0; transform: translateY(6px); }
        to   { opacity: 1; transform: translateY(0); }
      }

      .gs1-step-done   { animation: gs1-check-in 0.35s ease forwards; }
      .gs1-step-fade   { animation: gs1-fade-up 0.3s ease forwards; }

      .gs1-shimmer {
        position: relative;
        overflow: hidden;
        background: var(--gs1-gray-100);
      }
      .gs1-shimmer::after {
        content: "";
        position: absolute;
        inset: 0;
        background: linear-gradient(90deg,
          transparent 0%,
          rgba(255,255,255,.7) 50%,
          transparent 100%);
        animation: gs1-slide 1.6s infinite;
      }

      /* Input focus ring matches GS1 blue */
      .gs1-input:focus {
        outline: none;
        box-shadow: 0 0 0 2px rgba(0,80,160,.25);
        border-color: var(--gs1-blue-light);
      }
    </style>

    <div style="font-family:'DM Sans',system-ui,sans-serif; background:var(--gs1-gray-50); min-height:100vh;">
      <div style="max-width:1200px; margin:0 auto; padding:2rem 1.5rem;">
        <%!-- ── Header ─────────────────────────────────────────────────── --%>
        <div style="display:flex; align-items:center; gap:1rem; margin-bottom:2rem;">
          <%!-- GS1 barcode-stripe logo mark --%>

          <div>
            <div class="flex gap-2 items-center">
              <img src="/images/gs1.png" class="h-12  object-cover" />

              <h1 style="font-size:1.2rem; font-weight:700; color:var(--gs1-blue); letter-spacing:-.02em; margin:0;">
                GS1 Kenya Product Classifier
              </h1>
            </div>
            <p class="mt-4" style="font-size:.75rem; color:var(--gs1-gray-400); margin:0; margin-top: 20px">
              Upload · Review · Classify · Export
            </p>
          </div>
          <div style="margin-left:auto; display:flex; align-items:center; gap:.4rem; background:var(--gs1-blue); color:#fff; font-size:.7rem; font-weight:600; padding:.35rem .8rem; border-radius:999px; letter-spacing:.04em;">
            <div style="width:6px; height:6px; background:var(--gs1-orange); border-radius:50%;">
            </div>
            GS1 STANDARDS
          </div>
        </div>

        <%!-- ── Progress Steps ─────────────────────────────────────────── --%>
        <div style="background:#fff; border:1px solid var(--gs1-gray-200); border-radius:12px; padding:1.25rem 1.5rem; margin-bottom:1.5rem;">
          <ol style="display:flex; align-items:center; list-style:none; margin:0; padding:0; gap:0;">
            <%= for {step_name, step_label, step_icon, idx} <- [
              {:upload,   "Upload",   "📁", 1},
              {:review,   "Review",   "🔍", 2},
              {:analysed, "Classify", "🏷️", 3}
            ] do %>
              <li style={"display:flex; align-items:center; " <> if(idx < 3, do: "flex-1;", else: "")}>
                <div style="display:flex; align-items:center; gap:.6rem;">
                  <%!-- Circle --%>
                  <div style={"
                    width:2rem; height:2rem; border-radius:50%;
                    display:flex; align-items:center; justify-content:center;
                    font-size:.75rem; font-weight:700;
                    transition: background .2s, border-color .2s;
                    " <>
                    cond do
                      step_complete?(@step, step_name) ->
                        "background:var(--gs1-blue); border:2px solid var(--gs1-blue); color:#fff;"
                      @step == step_name ->
                        "background:var(--gs1-orange); border:2px solid var(--gs1-orange); color:#fff;"
                      true ->
                        "background:#fff; border:2px solid var(--gs1-gray-200); color:var(--gs1-gray-400);"
                    end
                  }>
                    <%= if step_complete?(@step, step_name) do %>
                      <svg width="14" height="14" viewBox="0 0 20 20" fill="currentColor">
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
                  <%!-- Label --%>
                  <span style={"font-size:.8rem; font-weight:600; " <>
                    cond do
                      @step == step_name -> "color:var(--gs1-blue);"
                      step_complete?(@step, step_name) -> "color:var(--gs1-gray-700);"
                      true -> "color:var(--gs1-gray-400);"
                    end
                  }>
                    {step_label}
                  </span>
                </div>
                <%!-- Connector line --%>
                <%= if idx < 3 do %>
                  <div style={"flex:1; height:2px; margin:0 1rem; border-radius:2px; " <>
                    if(step_complete?(@step, step_name),
                      do: "background:var(--gs1-blue);",
                      else: "background:var(--gs1-gray-200);")}>
                  </div>
                <% end %>
              </li>
            <% end %>
          </ol>
        </div>

        <%!-- ── Error Banner ─────────────────────────────────────────────── --%>
        <%= if @error do %>
          <div style="margin-bottom:1rem; background:#FFF0F0; border:1px solid #FFCCCC; color:var(--gs1-red); font-size:.8rem; padding:.75rem 1rem; border-radius:8px; display:flex; gap:.5rem; align-items:center;">
            <svg width="16" height="16" viewBox="0 0 20 20" fill="currentColor">
              <path
                fill-rule="evenodd"
                d="M10 18a8 8 0 100-16 8 8 0 000 16zm-1-9V7a1 1 0 112 0v2a1 1 0 11-2 0zm0 4a1 1 0 112 0 1 1 0 01-2 0z"
                clip-rule="evenodd"
              />
            </svg>
            {@error}
          </div>
        <% end %>

        <%!-- ════════════════════════════════════════════════════════════════
             STEP: UPLOAD
             ════════════════════════════════════════════════════════════════ --%>
        <%= case @step do %>
          <% :upload -> %>
            <div style="max-width:520px; margin:0 auto; background:#fff; border:1px solid var(--gs1-gray-200); border-radius:16px; padding:2.5rem; text-align:center;">
              <%!-- Icon --%>
              <div style="width:56px; height:56px; background:var(--gs1-blue); border-radius:14px; display:flex; align-items:center; justify-content:center; margin:0 auto 1.25rem;">
                <svg
                  width="26"
                  height="26"
                  fill="none"
                  stroke="white"
                  stroke-width="1.8"
                  viewBox="0 0 24 24"
                >
                  <path
                    stroke-linecap="round"
                    stroke-linejoin="round"
                    d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-8l-4-4m0 0L8 8m4-4v12"
                  />
                </svg>
              </div>
              <h3 style="font-size:1rem; font-weight:700; color:var(--gs1-blue); margin:0 0 .3rem;">
                Upload Product Data
              </h3>
              <p style="font-size:.78rem; color:var(--gs1-gray-400); margin:0 0 1.5rem;">
                CSV or Excel file with product codes, names & descriptions
              </p>

              <form phx-submit="upload" phx-change="validate">
                <div
                  style={"border:2px dashed var(--gs1-gray-200); border-radius:12px; padding:2rem 1.5rem; transition:border-color .2s; " <>
                    if(@uploads.product_csv.entries != [], do: "border-color:var(--gs1-blue-light);", else: "")}
                  phx-drop-target={@uploads.product_csv.ref}
                >
                  <label for={@uploads.product_csv.ref} style="cursor:pointer;">
                    <span style="display:inline-flex; align-items:center; gap:.4rem; padding:.5rem 1.1rem; background:var(--gs1-blue); color:#fff; font-size:.78rem; font-weight:600; border-radius:8px; transition:background .15s;">
                      <svg
                        width="13"
                        height="13"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2"
                        viewBox="0 0 24 24"
                      >
                        <path stroke-linecap="round" stroke-linejoin="round" d="M12 4v16m8-8H4" />
                      </svg>
                      Select File
                    </span>
                    <.live_file_input upload={@uploads.product_csv} class="sr-only" />
                  </label>
                  <p style="margin:.6rem 0 0; font-size:.75rem; color:var(--gs1-gray-400);">
                    or drag & drop here
                  </p>

                  <%= for entry <- @uploads.product_csv.entries do %>
                    <div style="margin-top:.8rem; display:inline-flex; align-items:center; gap:.5rem; background:var(--gs1-gray-50); border:1px solid var(--gs1-gray-200); border-radius:8px; padding:.4rem .75rem; font-size:.75rem; color:var(--gs1-gray-700);">
                      <svg width="12" height="12" fill="var(--gs1-blue)" viewBox="0 0 20 20">
                        <path d="M4 4a2 2 0 012-2h4l6 6v8a2 2 0 01-2 2H6a2 2 0 01-2-2V4z" />
                      </svg>
                      {entry.client_name}
                      <span style="color:var(--gs1-gray-400);">
                        ({format_bytes(entry.client_size)})
                      </span>
                    </div>
                  <% end %>
                </div>

                <%= if @uploads.product_csv.entries != [] do %>
                  <button
                    type="submit"
                    style="margin-top:1rem; width:100%; padding:.65rem; background:var(--gs1-orange); color:#fff; font-size:.85rem; font-weight:700; border:none; border-radius:8px; cursor:pointer; transition:background .15s; letter-spacing:.01em;"
                  >
                    Upload & Process →
                  </button>
                <% end %>
              </form>
            </div>

            <%!-- ════════════════════════════════════════════════════════════════
               STEP: REVIEW
               ════════════════════════════════════════════════════════════════ --%>
          <% :review -> %>
            <div style="background:#fff; border:1px solid var(--gs1-gray-200); border-radius:16px; overflow:hidden;">
              <div style="padding:1.1rem 1.4rem; border-bottom:1px solid var(--gs1-gray-100); display:flex; align-items:center; justify-content:space-between;">
                <div>
                  <h3 style="font-size:.9rem; font-weight:700; color:var(--gs1-blue); margin:0 0 .15rem;">
                    Review Uploaded Data
                  </h3>
                  <p style="font-size:.73rem; color:var(--gs1-gray-400); margin:0;">
                    Found {length(@products)} products — first 10 shown
                  </p>
                </div>
              </div>

              <div style="overflow-x:auto;">
                <table style="width:100%; border-collapse:collapse;">
                  <thead>
                    <tr style="background:var(--gs1-gray-50); border-bottom:1px solid var(--gs1-gray-100);">
                      <%= for label <- ["Code","Name","Description","Class."] do %>
                        <th style="padding:.65rem 1rem; text-align:left; font-size:.7rem; font-weight:700; color:var(--gs1-gray-400); text-transform:uppercase; letter-spacing:.07em; white-space:nowrap;">
                          {label}
                        </th>
                      <% end %>
                    </tr>
                  </thead>
                  <tbody>
                    <%= for product <- Enum.take(@products, 10) do %>
                      <tr style="border-bottom:1px solid var(--gs1-gray-100);">
                        <td style="padding:.6rem 1rem; font-size:.75rem; color:var(--gs1-gray-400); font-family:monospace;">
                          {product.code}
                        </td>
                        <td style="padding:.6rem 1rem; font-size:.75rem; color:var(--gs1-gray-700); font-weight:600;">
                          {product.name}
                        </td>
                        <td style="padding:.6rem 1rem; font-size:.75rem; color:var(--gs1-gray-400); max-width:20rem; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                          {product.description}
                        </td>
                        <td style="padding:.6rem 1rem; font-size:.75rem; color:var(--gs1-gray-400); font-family:monospace;">
                          {product.classification || "—"}
                        </td>
                      </tr>
                    <% end %>
                  </tbody>
                </table>
              </div>

              <div style="padding:.85rem 1.4rem; border-top:1px solid var(--gs1-gray-100); background:var(--gs1-gray-50); display:flex; align-items:center; justify-content:space-between;">
                <p style="font-size:.73rem; color:var(--gs1-gray-400); margin:0;">
                  {if length(@products) > 10,
                    do: "Showing 10 of #{length(@products)} products",
                    else: ""}
                </p>
                <div style="display:flex; gap:.5rem;">
                  <button
                    phx-click="reset"
                    style="padding:.45rem .9rem; border:1px solid var(--gs1-gray-200); background:#fff; border-radius:7px; font-size:.75rem; font-weight:600; color:var(--gs1-gray-700); cursor:pointer;"
                  >
                    Cancel
                  </button>
                  <button
                    phx-click="analyse_with_openai"
                    disabled={@processing}
                    style={"padding:.45rem 1.1rem; border:none; border-radius:7px; font-size:.75rem; font-weight:700; cursor:pointer; transition:background .15s; display:flex; align-items:center; gap:.5rem; " <>
                      if(@processing, do: "background:var(--gs1-blue-mid); color:#fff; opacity:.85;", else: "background:var(--gs1-orange); color:#fff;")}
                  >
                    <%= if @processing do %>
                      <svg
                        style="animation:gs1-spin .8s linear infinite;"
                        width="13"
                        height="13"
                        viewBox="0 0 24 24"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2.5"
                      >
                        <path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4M4.93 19.07l2.83-2.83M16.24 7.76l2.83-2.83" />
                      </svg>
                      {@analysis_progress || "Analysing…"}
                    <% else %>
                      Classify with GS1 AI →
                    <% end %>
                  </button>
                </div>
              </div>

              <%!-- ── Animated analysis steps modal overlay ────────────────────── --%>
              <%= if @processing do %>
                <div style="position:fixed; inset:0; background:rgba(0,20,60,.55); z-index:100; display:flex; align-items:center; justify-content:center; backdrop-filter:blur(4px);">
                  <div style="background:#fff; border-radius:20px; padding:2.5rem 2.75rem; width:440px; max-width:calc(100vw - 2rem); box-shadow:0 32px 80px rgba(0,20,60,.25);">
                    <%!-- GS1 logo row --%>
                    <div style="display:flex; align-items:center; gap:.75rem; margin-bottom:1.75rem;">
                      <div style="display:flex; align-items:flex-end; gap:1.5px; height:28px;">
                        <%= for w <- [2,4,1.5,5,1.5,3,2,6,1.5,4,2] do %>
                          <div style={"width:#{w}px; height:#{70 + :rand.uniform(30)}%; background:var(--gs1-blue); border-radius:1px;"}>
                          </div>
                        <% end %>
                      </div>
                      <div>
                        <p style="font-size:.65rem; font-weight:800; letter-spacing:.12em; color:var(--gs1-blue); margin:0;">
                          GS1 AI PRODUCT CLASSIFIER
                        </p>
                        <p style="font-size:.68rem; color:var(--gs1-gray-400); margin:0;">
                          Running classification pipeline…
                        </p>
                      </div>
                    </div>

                    <%!-- Overall progress bar --%>
                    <div style="height:4px; background:var(--gs1-gray-100); border-radius:4px; overflow:hidden; margin-bottom:1.75rem; position:relative;">
                      <div style="position:absolute; inset:0; background:linear-gradient(90deg, transparent, rgba(255,255,255,.6), transparent); animation:gs1-slide 1.4s infinite;">
                      </div>
                      <div style={"height:100%; background:linear-gradient(90deg, var(--gs1-blue), var(--gs1-orange)); border-radius:4px; transition:width .4s ease; width:" <>
                        (case @analysis_progress do
                          "Getting brand name…"    -> "20%"
                          "Reading descriptions…"  -> "40%"
                          "Checking GTINs…"        -> "62%"
                          "Assigning GS1 classes…" -> "84%"
                          _                        -> "10%"
                        end)
                      }>
                      </div>
                    </div>

                    <%!-- Step list --%>
                    <ul style="list-style:none; margin:0; padding:0; display:flex; flex-direction:column; gap:.9rem;">
                      <%= for {label, icon, active_phase} <- [
                        {"Extracting brand names",         "🏷️",  "Getting brand name…"},
                        {"Reading product descriptions",   "📋",  "Reading descriptions…"},
                        {"Validating GTINs (EAN-13)",       "🔢",  "Checking GTINs…"},
                        {"Assigning GS1 brick classes",    "📦",  "Assigning GS1 classes…"}
                      ] do %>
                        <% phase_order = %{
                          "Getting brand name…" => 1,
                          "Reading descriptions…" => 2,
                          "Checking GTINs…" => 3,
                          "Assigning GS1 classes…" => 4,
                          nil => 0
                        }

                        current_order = Map.get(phase_order, @analysis_progress, 0)
                        this_order = Map.get(phase_order, active_phase, 0)
                        is_done = current_order > this_order
                        is_active = @analysis_progress == active_phase %>
                        <li style={"display:flex; align-items:center; gap:.85rem; animation:gs1-fade-up .3s ease both; animation-delay:#{(this_order - 1) * 80}ms;"}>
                          <%!-- Status indicator --%>
                          <div style={"width:28px; height:28px; border-radius:50%; flex-shrink:0; display:flex; align-items:center; justify-content:center; font-size:.8rem; transition:all .25s; " <>
                            cond do
                              is_done   -> "background:var(--gs1-blue); animation:gs1-check-in .35s ease both;"
                              is_active -> "background:var(--gs1-orange-lt); border:2px solid var(--gs1-orange);"
                              true      -> "background:var(--gs1-gray-50); border:2px solid var(--gs1-gray-200);"
                            end
                          }>
                            <%= cond do %>
                              <% is_done -> %>
                                <svg width="12" height="12" viewBox="0 0 20 20" fill="white">
                                  <path
                                    fill-rule="evenodd"
                                    d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z"
                                    clip-rule="evenodd"
                                  />
                                </svg>
                              <% is_active -> %>
                                <svg
                                  style="animation:gs1-spin .8s linear infinite;"
                                  width="13"
                                  height="13"
                                  viewBox="0 0 24 24"
                                  fill="none"
                                  stroke="var(--gs1-orange)"
                                  stroke-width="2.5"
                                >
                                  <path d="M12 2v4M12 18v4M4.93 4.93l2.83 2.83M16.24 16.24l2.83 2.83M2 12h4M18 12h4" />
                                </svg>
                              <% true -> %>
                                <span style="font-size:.7rem;">{icon}</span>
                            <% end %>
                          </div>

                          <%!-- Label --%>
                          <div style="flex:1;">
                            <p style={"margin:0; font-size:.82rem; font-weight:600; " <>
                              cond do
                                is_done   -> "color:var(--gs1-blue);"
                                is_active -> "color:var(--gs1-gray-900);"
                                true      -> "color:var(--gs1-gray-400);"
                              end
                            }>
                              {label}
                            </p>
                            <%= if is_active do %>
                              <%!-- Shimmer skeleton text --%>
                              <div style="margin-top:.3rem; display:flex; gap:.4rem;">
                                <div
                                  class="gs1-shimmer"
                                  style="height:8px; width:60%; border-radius:4px;"
                                >
                                </div>
                                <div
                                  class="gs1-shimmer"
                                  style="height:8px; width:25%; border-radius:4px;"
                                >
                                </div>
                              </div>
                            <% end %>
                            <%= if is_done do %>
                              <p style="margin:.1rem 0 0; font-size:.7rem; color:var(--gs1-gray-400);">
                                Complete
                              </p>
                            <% end %>
                          </div>

                          <%!-- Pill badge --%>
                          <%= cond do %>
                            <% is_done -> %>
                              <span style="font-size:.65rem; font-weight:700; color:var(--gs1-blue); background:#EBF2FF; padding:.2rem .6rem; border-radius:999px; letter-spacing:.03em;">
                                DONE
                              </span>
                            <% is_active -> %>
                              <span style="font-size:.65rem; font-weight:700; color:var(--gs1-orange); background:var(--gs1-orange-lt); padding:.2rem .6rem; border-radius:999px; letter-spacing:.03em; animation:gs1-pulse 1.2s infinite;">
                                RUNNING
                              </span>
                            <% true -> %>
                              <span style="font-size:.65rem; font-weight:700; color:var(--gs1-gray-400); background:var(--gs1-gray-100); padding:.2rem .6rem; border-radius:999px; letter-spacing:.03em;">
                                QUEUED
                              </span>
                          <% end %>
                        </li>
                      <% end %>
                    </ul>

                    <p style="margin:1.5rem 0 0; font-size:.72rem; color:var(--gs1-gray-400); text-align:center;">
                      Do not close this window — processing {length(@products)} products
                    </p>
                  </div>
                </div>
              <% end %>
            </div>

            <%!-- ════════════════════════════════════════════════════════════════
               STEP: ANALYSED
               ════════════════════════════════════════════════════════════════ --%>
          <% :analysed -> %>
            <% total_rows = length(@reviewed_products)

            error_count =
              count_reviewed_errors(@duplicate_indices, @invalid_gtin_indices || MapSet.new())

            no_class_count = count_no_classification(@reviewed_products)
            valid_count = total_rows - error_count %>

            <div style="display:flex; flex-direction:column; gap:1rem;">
              <%!-- Stat cards --%>
              <div style="display:grid; grid-template-columns:repeat(4,1fr); gap:.75rem;">
                <%= for {label, value, bg, fg, border} <- [
                  {"Total Rows",   total_rows,     "#fff",                     "var(--gs1-gray-900)",  "var(--gs1-gray-200)"},
                  {"Valid",        valid_count,     "#EDFAF3",                  "var(--gs1-green)",     "#C0EDDA"},
                  {"Errors",       error_count,     if(error_count > 0, do: "#FFF0F0", else: "#fff"),   if(error_count > 0, do: "var(--gs1-red)", else: "var(--gs1-gray-900)"),    if(error_count > 0, do: "#FFCCCC", else: "var(--gs1-gray-200)")},
                  {"No Class.",    no_class_count,  if(no_class_count > 0, do: "#FFFBF0", else: "#fff"), if(no_class_count > 0, do: "var(--gs1-amber)", else: "var(--gs1-gray-900)"), if(no_class_count > 0, do: "#FFE4A0", else: "var(--gs1-gray-200)")}
                ] do %>
                  <div style={"background:#{bg}; border:1px solid #{border}; border-radius:12px; padding:.9rem 1.1rem;"}>
                    <p style={"font-size:1.7rem; font-weight:800; color:#{fg}; margin:0; line-height:1.1;"}>
                      {value}
                    </p>
                    <p style="font-size:.68rem; color:var(--gs1-gray-400); margin:.25rem 0 0; text-transform:uppercase; letter-spacing:.07em; font-weight:600;">
                      {label}
                    </p>
                  </div>
                <% end %>
              </div>

              <%!-- Editable table --%>
              <div style="background:#fff; border:1px solid var(--gs1-gray-200); border-radius:16px; overflow:hidden;">
                <div style="padding:1rem 1.4rem; border-bottom:1px solid var(--gs1-gray-100); display:flex; align-items:center; justify-content:space-between;">
                  <div>
                    <h3 style="font-size:.9rem; font-weight:700; color:var(--gs1-blue); margin:0 0 .15rem;">
                      AI Reviewed — Editable
                    </h3>
                    <p style="font-size:.7rem; color:var(--gs1-gray-400); margin:0;">
                      Grey rows = original. Edit any field, click away to save.
                      <span style="color:var(--gs1-red);">Red rows</span>
                      = duplicate codes or invalid EAN-13 GTIN.
                    </p>
                  </div>
                </div>

                <div style="overflow-x:auto;">
                  <table style="width:100%; border-collapse:collapse;">
                    <thead>
                      <tr style="background:var(--gs1-gray-50); border-bottom:1px solid var(--gs1-gray-100);">
                        <%= for label <- ["Code","Name","Description","Weight","UOM","Class.","Market",""] do %>
                          <th style="padding:.6rem .85rem; text-align:left; font-size:.68rem; font-weight:700; color:var(--gs1-gray-400); text-transform:uppercase; letter-spacing:.07em; white-space:nowrap;">
                            {label}
                          </th>
                        <% end %>
                      </tr>
                    </thead>
                    <tbody>
                      <%= for {p, idx} <- Enum.with_index(@reviewed_products) do %>
                        <% orig = Map.get(p, :original)
                        is_dup = MapSet.member?(@duplicate_indices, idx)
                        gtin_error = Map.get(@gtin_errors || %{}, idx)
                        is_invalid_gtin = gtin_error != nil
                        has_error = is_dup or is_invalid_gtin %>

                        <%!-- Original row --%>
                        <%= if orig do %>
                          <tr style={"background:var(--gs1-gray-50); " <> if(has_error, do: "border-left:3px solid #FFAAAA;", else: "border-left:3px solid transparent;")}>
                            <%= for val <- [orig[:code], orig[:name], orig[:description], orig[:weight], orig[:uom], orig[:classification], orig[:target_market]] do %>
                              <td style="padding:.35rem .85rem; font-size:.7rem; color:var(--gs1-gray-400); font-family:monospace; max-width:14rem; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                {format_cell(val)}
                              </td>
                            <% end %>
                            <td></td>
                          </tr>
                        <% end %>

                        <%!-- Editable row --%>
                        <tr
                          style={"" <> if(has_error, do: "background:#FFF5F5; border-left:3px solid var(--gs1-red);", else: "background:#fff; border-left:3px solid transparent;")}
                          title={
                            [
                              (if is_dup, do: "Duplicate barcode — double allocation", else: nil),
                              (if is_invalid_gtin, do: "Invalid EAN-13 GTIN", else: nil)
                            ]
                            |> Enum.reject(&is_nil/1)
                            |> Enum.join(" · ")
                            |> then(fn s -> if s == "", do: nil, else: s end)
                          }
                        >
                          <%!-- Code --%>
                          <td style="padding:.4rem .6rem; vertical-align:top;">
                            <input
                              type="text"
                              name={"#{idx}:code"}
                              value={format_cell(p.code)}
                              phx-blur="update_reviewed_product"
                              phx-value-index={idx}
                              phx-value-field="code"
                              class="gs1-input"
                              style={"width:7rem; font-size:.75rem; font-family:monospace; border-radius:6px; padding:.35rem .5rem; border:1px solid; " <>
                                if(has_error, do: "border-color:#FFAAAA; background:#FFF5F5;", else: "border-color:var(--gs1-gray-200);")}
                            />
                            <%= if is_dup do %>
                              <p style="margin:.25rem 0 0; font-size:.65rem; color:var(--gs1-red); line-height:1.3;">Duplicate code</p>
                            <% end %>
                            <%= if gtin_error do %>
                              <p style="margin:.25rem 0 0; font-size:.65rem; color:var(--gs1-red); line-height:1.3;">{gtin_error}</p>
                            <% end %>
                          </td>
                          <%!-- Name --%>
                          <td style="padding:.4rem .6rem;">
                            <input
                              type="text"
                              name={"#{idx}:name"}
                              value={p.name}
                              phx-blur="update_reviewed_product"
                              phx-value-index={idx}
                              phx-value-field="name"
                              class="gs1-input"
                              style="min-width:8rem; font-size:.75rem; border-radius:6px; padding:.35rem .5rem; border:1px solid var(--gs1-gray-200);"
                            />
                          </td>
                          <%!-- Description --%>
                          <td style="padding:.4rem .6rem; vertical-align:top;">
                            <textarea
                              name={"#{idx}:description"}
                              phx-blur="update_reviewed_product"
                              phx-value-index={idx}
                              phx-value-field="description"
                              rows="2"
                              class="gs1-input"
                              style="min-width:14rem; width:100%; font-size:.75rem; border-radius:6px; padding:.35rem .5rem; border:1px solid var(--gs1-gray-200); resize:vertical; line-height:1.45;"
                            >{p.description}</textarea>
                          </td>
                          <%!-- Weight --%>
                          <td style="padding:.4rem .6rem;">
                            <input
                              type="text"
                              name={"#{idx}:weight"}
                              value={format_cell(p.weight)}
                              phx-blur="update_reviewed_product"
                              phx-value-index={idx}
                              phx-value-field="weight"
                              class="gs1-input"
                              style="width:4rem; font-size:.75rem; border-radius:6px; padding:.35rem .5rem; border:1px solid var(--gs1-gray-200);"
                            />
                          </td>
                          <%!-- UOM --%>
                          <td style="padding:.4rem .6rem;">
                            <select
                              name={"#{idx}:uom"}
                              phx-change="update_reviewed_product"
                              phx-value-index={idx}
                              phx-value-field="uom"
                              class="gs1-input"
                              style="width:5.5rem; font-size:.75rem; border-radius:6px; padding:.35rem .5rem; border:1px solid var(--gs1-gray-200); background:#fff; cursor:pointer;"
                            >
                              <option value="">—</option>
                              <option value="MLT" selected={p.uom == "MLT"}>MLT</option>
                              <option value="LTR" selected={p.uom == "LTR"}>LTR</option>
                              <option value="CTL" selected={p.uom == "CTL"}>CTL</option>
                              <option value="GRM" selected={p.uom == "GRM"}>GRM</option>
                              <option value="KGM" selected={p.uom == "KGM"}>KGM</option>
                              <option value="MTR" selected={p.uom == "MTR"}>MTR</option>
                              <option value="CMT" selected={p.uom == "CMT"}>CMT</option>
                              <option value="MMT" selected={p.uom == "MMT"}>MMT</option>
                              <option value="INH" selected={p.uom == "INH"}>INH</option>
                              <option value="PK" selected={p.uom == "PK"}>PK</option>
                              <option value="PA" selected={p.uom == "PA"}>PA</option>
                              <option value="DZN" selected={p.uom == "DZN"}>DZN</option>
                              <option value="PR" selected={p.uom == "PR"}>PR</option>
                              <option value="ZP" selected={p.uom == "ZP"}>ZP</option>
                              <option value="H87" selected={p.uom == "H87"}>H87</option>
                              <option value="U2" selected={p.uom == "U2"}>U2</option>
                              <option value="AV" selected={p.uom == "AV"}>AV</option>
                              <option value="ONZ" selected={p.uom == "ONZ"}>ONZ</option>
                              <option value="LTN" selected={p.uom == "LTN"}>LTN</option>
                              <option value="AMP" selected={p.uom == "AMP"}>AMP</option>
                              <option value="KWT" selected={p.uom == "KWT"}>KWT</option>
                              <option value="WTT" selected={p.uom == "WTT"}>WTT</option>
                              <option value="VLT" selected={p.uom == "VLT"}>VLT</option>
                              <option value="KVT" selected={p.uom == "KVT"}>KVT</option>
                            </select>
                          </td>
                          <%!-- Classification --%>
                          <td style="padding:.4rem .6rem; vertical-align:top; position:relative;">
                            <div style="display:flex; align-items:center; gap:.5rem;">
                              <input
                                type="text"
                                name={"#{idx}:classification"}
                                value={format_cell(p.classification)}
                                phx-blur="update_reviewed_product"
                                phx-value-index={idx}
                                phx-value-field="classification"
                                class="gs1-input"
                                style="width:5.5rem; font-size:.75rem; font-family:monospace; border-radius:6px; padding:.35rem .5rem; border:1px solid var(--gs1-gray-200);"
                              />
                              <button
                                type="button"
                                phx-click="suggest_similar_classes"
                                phx-value-index={idx}
                                style="font-size:.68rem; font-weight:700; color:var(--gs1-blue-light); background:none; border:none; cursor:pointer; white-space:nowrap; padding:0; text-decoration:underline; text-underline-offset:2px;"
                              >
                                View Similar
                              </button>
                            </div>
                            <% desc =
                              Map.get(@classification_descriptions, format_cell(p.classification)) %>
                            <%= if is_binary(desc) && desc != "" do %>
                              <p
                                style="margin:.2rem 0 0; font-size:.65rem; color:var(--gs1-blue-light); font-style:italic; max-width:13rem; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;"
                                title={desc}
                              >
                                {desc}
                              </p>
                            <% end %>

                            <%!-- Suggestions dropdown --%>
                            <% row_suggestions = Map.get(@classification_suggestions || %{}, idx) %>
                            <%= if row_suggestions != nil do %>
                              <div
                                id={"similar-suggestions-#{idx}"}
                                phx-hook="ClickAway"
                                data-index={idx}
                                style="position:absolute; left:0; top:100%; margin-top:6px; width:280px; background:#fff; border:1px solid var(--gs1-gray-200); border-radius:12px; box-shadow:0 16px 40px rgba(0,20,60,.12); z-index:50; overflow:hidden;"
                              >
                                <div style="display:flex; align-items:center; justify-content:space-between; padding:.5rem .75rem; border-bottom:1px solid var(--gs1-gray-100); background:var(--gs1-gray-50);">
                                  <span style="font-size:.65rem; font-weight:700; color:var(--gs1-gray-400); text-transform:uppercase; letter-spacing:.1em;">
                                    Choose a class
                                  </span>
                                  <button
                                    type="button"
                                    phx-click="clear_similar_suggestions"
                                    phx-value-index={idx}
                                    style="background:none; border:none; cursor:pointer; color:var(--gs1-gray-400); padding:.15rem; display:flex;"
                                  >
                                    <svg
                                      width="11"
                                      height="11"
                                      fill="none"
                                      stroke="currentColor"
                                      stroke-width="2.5"
                                      viewBox="0 0 24 24"
                                    >
                                      <path
                                        stroke-linecap="round"
                                        stroke-linejoin="round"
                                        d="M6 18L18 6M6 6l12 12"
                                      />
                                    </svg>
                                  </button>
                                </div>
                                <ul style="list-style:none; margin:0; padding:0; max-height:14rem; overflow-y:auto;">
                                  <%= if row_suggestions == [] do %>
                                    <li style="padding:1.5rem; text-align:center; font-size:.75rem; color:var(--gs1-gray-400);">
                                      No similar classes found.
                                    </li>
                                  <% else %>
                                    <%= for sug <- row_suggestions do %>
                                      <% is_current = format_cell(p.classification) == sug.brick %>
                                      <li>
                                        <button
                                          type="button"
                                          phx-click="apply_suggestion"
                                          phx-value-index={idx}
                                          phx-value-brick={sug.brick}
                                          style={"width:100%; text-align:left; padding:.6rem .75rem; border:none; cursor:pointer; transition:background .1s; " <>
                                            if(is_current, do: "background:#EBF2FF;", else: "background:#fff;")}
                                        >
                                          <div style="display:flex; align-items:center; gap:.4rem; margin-bottom:.15rem;">
                                            <span style={"font-family:monospace; font-size:.72rem; font-weight:700; " <>
                                              if(is_current, do: "color:var(--gs1-blue);", else: "color:var(--gs1-gray-400);")}>
                                              {sug.brick}
                                            </span>
                                            <%= if is_current do %>
                                              <span style="font-size:.6rem; background:var(--gs1-blue); color:#fff; font-weight:700; padding:.1rem .45rem; border-radius:999px; letter-spacing:.05em;">
                                                CURRENT
                                              </span>
                                            <% end %>
                                          </div>
                                          <p style={"font-size:.72rem; margin:0; line-height:1.35; " <> if(is_current, do: "color:var(--gs1-blue-mid); font-weight:600;", else: "color:var(--gs1-gray-700);")}>
                                            {sug.description}
                                          </p>
                                          <%= if Map.get(sug, :class_title, "") != "" do %>
                                            <p style="font-size:.65rem; color:var(--gs1-gray-400); margin:.1rem 0 0; overflow:hidden; text-overflow:ellipsis; white-space:nowrap;">
                                              {sug.class_title}
                                            </p>
                                          <% end %>
                                        </button>
                                      </li>
                                    <% end %>
                                  <% end %>
                                </ul>
                              </div>
                            <% end %>
                          </td>
                          <%!-- Target Market --%>
                          <td style="padding:.4rem .6rem;">
                            <input
                              type="text"
                              name={"#{idx}:target_market"}
                              value={p.target_market}
                              phx-blur="update_reviewed_product"
                              phx-value-index={idx}
                              phx-value-field="target_market"
                              class="gs1-input"
                              style="width:3.5rem; font-size:.75rem; border-radius:6px; padding:.35rem .5rem; border:1px solid var(--gs1-gray-200);"
                            />
                          </td>
                          <%!-- Delete --%>
                          <td style="padding:.4rem .6rem;">
                            <button
                              type="button"
                              phx-click="delete_reviewed_row"
                              phx-value-index={idx}
                              style="font-size:.7rem; font-weight:600; color:var(--gs1-gray-400); background:none; border:none; cursor:pointer; padding:.25rem .5rem; border-radius:5px; transition:color .1s;"
                              onmouseover="this.style.color='var(--gs1-red)'"
                              onmouseout="this.style.color='var(--gs1-gray-400)'"
                            >
                              Delete
                            </button>
                          </td>
                        </tr>

                        <%!-- Row divider --%>
                        <tr>
                          <td
                            colspan="8"
                            style="padding:0; height:1px; background:var(--gs1-gray-100);"
                          >
                          </td>
                        </tr>
                      <% end %>
                    </tbody>
                  </table>
                </div>

                <%!-- Table footer --%>
                <div style="padding:.85rem 1.4rem; border-top:1px solid var(--gs1-gray-100); background:var(--gs1-gray-50); display:flex; align-items:center; justify-content:space-between; border-radius:0 0 16px 16px;">
                  <p style="font-size:.7rem; color:var(--gs1-gray-400); margin:0;">
                    {length(@reviewed_products)} rows — edit any cell and click away to save
                  </p>
                  <div style="display:flex; gap:.5rem;">
                    <button
                      phx-click="reset"
                      style="padding:.45rem .9rem; border:1px solid var(--gs1-gray-200); background:#fff; border-radius:7px; font-size:.75rem; font-weight:600; color:var(--gs1-gray-700); cursor:pointer;"
                    >
                      Start Over
                    </button>
                    <button
                      phx-click="export_csv"
                      style="padding:.45rem 1.1rem; border:none; background:var(--gs1-blue); color:#fff; border-radius:7px; font-size:.75rem; font-weight:700; cursor:pointer; display:flex; align-items:center; gap:.4rem;"
                    >
                      <svg
                        width="12"
                        height="12"
                        fill="none"
                        stroke="currentColor"
                        stroke-width="2.2"
                        viewBox="0 0 24 24"
                      >
                        <path
                          stroke-linecap="round"
                          stroke-linejoin="round"
                          d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"
                        />
                      </svg>
                      Save as CSV
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <%!-- ════════════════════════════════════════════════════════════════
               STEP: CLASSIFIED (legacy results view)
               ════════════════════════════════════════════════════════════════ --%>
          <% :classified -> %>
            <div style="background:#fff; border:1px solid var(--gs1-gray-200); border-radius:16px; overflow:hidden;">
              <div style="padding:1.1rem 1.4rem; border-bottom:1px solid var(--gs1-gray-100);">
                <h3 style="font-size:.9rem; font-weight:700; color:var(--gs1-blue); margin:0;">
                  Classification Results
                </h3>
              </div>
              <div style="display:grid; grid-template-columns:repeat(3,1fr); gap:.75rem; padding:1.1rem 1.4rem;">
                <%= for {label, value, bg, fg, border} <- [
                  {"Total",         length(@classified_products), "#F7F8FA", "var(--gs1-gray-900)", "var(--gs1-gray-200)"},
                  {"Classified",    count_classified(@classified_products), "#EDFAF3", "var(--gs1-green)", "#C0EDDA"},
                  {"Needs Review",  count_needs_review(@classified_products), "#FFFBF0", "var(--gs1-amber)", "#FFE4A0"}
                ] do %>
                  <div style={"background:#{bg}; border:1px solid #{border}; border-radius:10px; padding:.85rem 1rem;"}>
                    <p style={"font-size:1.7rem; font-weight:800; color:#{fg}; margin:0; line-height:1.1;"}>
                      {value}
                    </p>
                    <p style="font-size:.68rem; color:var(--gs1-gray-400); margin:.2rem 0 0; text-transform:uppercase; letter-spacing:.07em; font-weight:600;">
                      {label}
                    </p>
                  </div>
                <% end %>
              </div>
              <div style="overflow-x:auto; border-top:1px solid var(--gs1-gray-100);">
                <table style="width:100%; border-collapse:collapse;">
                  <thead>
                    <tr style="background:var(--gs1-gray-50); border-bottom:1px solid var(--gs1-gray-100);">
                      <%= for label <- ["Product","Brick","Classification","Confidence",""] do %>
                        <th style="padding:.6rem 1rem; text-align:left; font-size:.68rem; font-weight:700; color:var(--gs1-gray-400); text-transform:uppercase; letter-spacing:.07em;">
                          {label}
                        </th>
                      <% end %>
                    </tr>
                  </thead>
                  <tbody>
                    <%= for {product, idx} <- Enum.with_index(@classified_products) do %>
                      <% orig = Map.get(product, :original) %>
                      <%= if orig do %>
                        <tr style="background:var(--gs1-gray-50);">
                          <td
                            colspan="5"
                            style="padding:.4rem 1rem; font-size:.7rem; color:var(--gs1-gray-400);"
                          >
                            <strong style="color:var(--gs1-gray-700);">Original:</strong>
                            {format_cell(orig[:code])} · {format_cell(orig[:name])} · {format_cell(
                              orig[:description]
                            )}
                          </td>
                        </tr>
                      <% end %>
                      <tr style="border-bottom:1px solid var(--gs1-gray-100);">
                        <td style="padding:.7rem 1rem;">
                          <p style="font-size:.8rem; font-weight:600; color:var(--gs1-gray-900); margin:0 0 .2rem;">
                            {product.name}
                          </p>
                          <p style="font-size:.7rem; color:var(--gs1-gray-400); margin:0;">
                            {product.description}
                          </p>
                        </td>
                        <td style="padding:.7rem 1rem; font-family:monospace; font-size:.78rem; font-weight:700; color:var(--gs1-blue);">
                          {product.suggested_classification.brick}
                        </td>
                        <td style="padding:.7rem 1rem; font-size:.75rem; color:var(--gs1-gray-700);">
                          {product.suggested_classification.description}
                        </td>
                        <td style="padding:.7rem 1rem;">
                          {render_confidence_badge(product.suggested_classification.confidence)}
                        </td>
                        <td style="padding:.7rem 1rem;">
                          <button
                            phx-click="edit_classification"
                            phx-value-index={idx}
                            style="font-size:.7rem; font-weight:700; color:var(--gs1-blue-light); background:none; border:none; cursor:pointer; text-decoration:underline; text-underline-offset:2px;"
                          >
                            Edit
                          </button>
                        </td>
                      </tr>
                    <% end %>
                  </tbody>
                </table>
              </div>
              <div style="padding:.85rem 1.4rem; border-top:1px solid var(--gs1-gray-100); display:flex; justify-content:flex-end; gap:.5rem; background:var(--gs1-gray-50); border-radius:0 0 16px 16px;">
                <button
                  phx-click="reset"
                  style="padding:.45rem .9rem; border:1px solid var(--gs1-gray-200); background:#fff; border-radius:7px; font-size:.75rem; font-weight:600; color:var(--gs1-gray-700); cursor:pointer;"
                >
                  Start Over
                </button>
                <button
                  phx-click="export_pdf"
                  disabled={@processing}
                  style={"padding:.45rem 1.1rem; border:none; border-radius:7px; font-size:.75rem; font-weight:700; cursor:pointer; " <>
                    if(@processing, do: "background:var(--gs1-green); color:#fff; opacity:.7;", else: "background:var(--gs1-green); color:#fff;")}
                >
                  {if @processing, do: "Generating…", else: "Export as PDF"}
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

  # Returns a specific error reason string, or nil if the code is a valid EAN-13
  defp gtin_error_reason(nil), do: "Code is empty"
  defp gtin_error_reason(""), do: "Code is empty"

  defp gtin_error_reason(code) when is_binary(code) do
    raw = String.trim(code)

    cond do
      raw == "" ->
        "Code is empty"

      String.match?(raw, ~r/[^\d]/) ->
        "Contains non-numeric characters"

      String.length(raw) < 13 ->
        "Too short — #{String.length(raw)} digit#{if String.length(raw) == 1, do: "", else: "s"}, need 13"

      String.length(raw) > 13 ->
        "Too long — #{String.length(raw)} digits, need 13"

      true ->
        list = String.graphemes(raw) |> Enum.map(&String.to_integer/1)
        weights = [1, 3, 1, 3, 1, 3, 1, 3, 1, 3, 1, 3]
        sum = Enum.zip(Enum.take(list, 12), weights) |> Enum.map(fn {d, w} -> d * w end) |> Enum.sum()
        expected_check = rem(10 - rem(sum, 10), 10)
        actual_check = Enum.at(list, 12)

        if actual_check == expected_check do
          nil
        else
          "Wrong check digit (got #{actual_check}, expected #{expected_check})"
        end
    end
  end

  defp gtin_error_reason(_), do: "Invalid code format"

  # Returns a map of %{index => reason_string} for all invalid GTINs
  defp gtin_errors_map(products) do
    products
    |> Enum.with_index()
    |> Enum.reduce(%{}, fn {p, idx}, acc ->
      code = (p[:code] || p["code"]) |> to_string() |> String.trim()
      case gtin_error_reason(code) do
        nil -> acc
        reason -> Map.put(acc, idx, reason)
      end
    end)
  end

  # Keep a plain MapSet of invalid indices for backward-compat with count helpers
  defp invalid_gtin_indices(products) do
    gtin_errors_map(products) |> Map.keys() |> MapSet.new()
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

  defp count_reviewed_errors(dup_set, gtin_set, desc_dup_set \\ MapSet.new()) do
    dup_set
    |> MapSet.union(gtin_set)
    |> MapSet.union(desc_dup_set)
    |> MapSet.size()
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
