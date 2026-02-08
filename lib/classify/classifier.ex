defmodule Classify.Classifier do
  @moduledoc """
  Product classification using GS1 brick codes. Uses in-memory Classifications
  (class_classifications.ex) only — no database.
  """

  alias Classify.Classifications

  @doc """
  Classify a product based on its description and name.
  Returns the best matching classification with confidence score.
  Uses in-memory Classifications only.
  """
  def classify_product(description, name) do
    search_text = "#{name} #{description}" |> String.downcase()
    keywords = extract_keywords(search_text)

    classifications =
      keywords
      |> Enum.flat_map(&Classifications.search/1)
      |> Enum.uniq_by(& &1.brick)
      |> Enum.take(20)

    best_match = find_best_match(search_text, classifications)

    case best_match do
      {classification, confidence} ->
        %{
          brick: classification.brick,
          description: classification.description,
          confidence: confidence
        }

      nil ->
        %{
          brick: "00000000",
          description: "Unclassified - Needs Manual Review",
          confidence: 0.0
        }
    end
  end

  @doc """
  Get a classification by brick code. Uses in-memory Classifications only.
  """
  def get_classification_by_brick(brick_code) do
    case Classifications.get_by_brick(brick_code) do
      nil ->
        %{
          brick: brick_code,
          description: "Unknown Classification",
          confidence: 0.0
        }

      c ->
        %{
          brick: c.brick,
          description: c.description,
          confidence: 1.0
        }
    end
  end

  @doc """
  Search classifications by keyword. Uses in-memory Classifications only.
  """
  def search_classifications(query, limit \\ 20) when is_binary(query) do
    query
    |> String.downcase()
    |> extract_keywords()
    |> Enum.flat_map(&Classifications.search/1)
    |> Enum.uniq_by(& &1.brick)
    |> Enum.take(limit)
  end

  @doc """
  List all classifications for dropdown/autocomplete. In-memory only.
  """
  def list_classifications do
    Classifications.all()
  end

  defp find_best_match(search_text, classifications) do
    keywords = extract_keywords(search_text)

    classifications
    |> Enum.map(fn c -> {c, calculate_match_score(keywords, c.description)} end)
    |> Enum.filter(fn {_c, score} -> score > 0.3 end)
    |> Enum.sort_by(fn {_c, score} -> score end, :desc)
    |> List.first()
  end

  defp calculate_match_score(keywords, description) do
    description_lower = String.downcase(description)
    description_words = String.split(description_lower, ~r/\s+/)

    matching =
      Enum.count(keywords, fn keyword ->
        Enum.any?(description_words, fn word ->
          String.contains?(word, keyword) or String.jaro_distance(word, keyword) > 0.8
        end)
      end)

    if length(keywords) > 0, do: matching / length(keywords), else: 0.0
  end

  defp extract_keywords(text) do
    stopwords =
      ~w(a an the and or but for of in on at to from by with is are was were be been being have has had ml mlt ltr litre liter kg gram grams kilogram purified water bottle pack)

    text
    |> String.downcase()
    |> String.replace(~r/[^\w\s]/, " ")
    |> String.split(~r/\s+/, trim: true)
    |> Enum.reject(&(&1 in stopwords))
    |> Enum.reject(&(String.length(&1) < 3))
    |> Enum.uniq()
  end
end
