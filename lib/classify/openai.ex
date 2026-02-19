defmodule Classify.OpenAI do
  require Logger

  def send_request_to_openai(context, prompt) do
    api_url = "https://api.openai.com/v1/chat/completions"

    api_key =
      Application.get_env(:classify, :openai_api_key)

    model =
      "gpt-4.1"

    body = %{
      "model" => model,
      "messages" => [
        %{
          "role" => "system",
          "content" => context
        },
        %{"role" => "user", "content" => prompt}
      ]
    }

    if !is_binary(api_key) or byte_size(api_key) == 0 do
      Logger.error("Missing OPENAI_API_KEY; cannot call OpenAI")
      {:error, :missing_openai_api_key}
    else
      headers = [
        {"Content-Type", "application/json"},
        {"Authorization", "Bearer #{api_key}"}
      ]

      options = [
        headers: headers,
        json: body,
        retry: :transient,
        max_retries: 10,
        receive_timeout: 60_000
      ]

      case Req.post(api_url, options) do
        {:ok, %{status: 200, body: %{"choices" => [%{"message" => %{"content" => content}} | _]}}} ->
          {:ok, content}

        {:ok, %{status: 200, body: %{"choices" => []}}} ->
          {:error, ""}

        {:ok, %{status: _status, body: body}} ->
          Logger.warning("OpenAI error response: #{inspect(body)}")
          {:error, ""}

        {:error, reason} ->
          Logger.warning("OpenAI request error: #{inspect(reason)}")
          {:error, ""}
      end
    end
  end
end
