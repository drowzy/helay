defmodule HelayClient.Transform.HTTP do
  @behaviour HelayClient.Transform.Transformable
  use Tesla
  require Logger
  alias HelayClient.{Transform, HTTP}

  adapter(Tesla.Adapter.Hackney)

  def run(%Transform{type: :http, args: args, input: input}) do
    http_client = HTTP.client(args)

    case http_client.(input) do
      {:ok, response} ->
        Logger.info("Http transforms returned #{inspect(response)} #{response.status}")
        # TODO might want to check resp headers
        {:ok, decode(response)}

      {:error, reason} = error ->
        Logger.error("Http transforms returned error #{inspect(reason)}")
        error
    end
  end

  defp decode(%Tesla.Env{body: ""}), do: %Transform{output: ""}
  defp decode(%Tesla.Env{body: body, headers: headers}) do
    json? = HTTP.has_content_type?(headers, "application/json")
    output = if json?, do: Poison.decode!(body), else: body

    Transform.new(output: output)
  end
end
