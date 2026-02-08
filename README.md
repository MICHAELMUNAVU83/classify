# Classify

**Live:** [classify.michaelmunavu.com](https://classify.michaelmunavu.com)

A product classification web app: upload product data (CSV or Excel), review it, run AI-powered cleaning and classification, then export to CSV.

## What it does

1. **Upload** – Upload a CSV or XLSX file with product information (e.g. code, name, description).
2. **Review** – Inspect the parsed data and column mapping before running AI.
3. **Analyse** – Send batches to OpenAI to:
   - Normalise descriptions (product name + weight + unit, sentence case)
   - Extract or infer weight, UOM (MLT/LTR), GS1 brick code (8-digit classification), and target market (e.g. KE)
   - Use your in-app classification list to keep responses consistent and token-efficient

After analysis you get an editable table: fix any cell, delete rows, and see **duplicate product codes highlighted in red**. When you’re done, **Save as CSV**.

## Tech

- [Phoenix](https://www.phoenixframework.org/) + [LiveView](https://hexdocs.pm/phoenix_live_view)
- OpenAI API for cleaning/classification
- Elixir, Ecto, ETS for classification lookup

## Setup

  * Install and setup: `mix setup`
  * Start server: `mix phx.server` (or `iex -S mix phx.server`)

Then open [http://localhost:4000](http://localhost:4000).

### Configuration

- **OpenAI:** Set your API key and model in `config/runtime.exs` (or via env). The app uses a system prompt plus a compact list of valid GS1 brick codes for each batch.

For production deployment, see [Phoenix deployment](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * [Phoenix](https://www.phoenixframework.org/)
  * [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view)
  * [Phoenix deployment](https://hexdocs.pm/phoenix/deployment.html)
