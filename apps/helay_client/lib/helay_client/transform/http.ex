defmodule HelayClient.Transform.HTTP do
  @behaviour HelayClient.Transform.Transformable
  use Tesla
  require Logger
  alias HelayClient.{Transform, Utils}

  adapter(Tesla.Adapter.Hackney)

  def run(%Transform{type: :http, args: args, input: input}) do
    http_client = client(args)

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

  def client(args) do
    method = parse_method(args["method"])
    headers = parse_headers(args["headers"])
    uri = String.trim(args["uri"])
    provided_body = args["body"]

    case method do
      m when m in [:post, :put, :patch] ->
        fn body ->
          apply(Tesla, m, [uri, encode_body(provided_body, body), [headers: headers]])
        end

      m when m in [:get, :delete, :head] ->
        fn _arg -> apply(Tesla, m, [uri, [headers: headers]]) end

      _ ->
        :error
    end
  end

  defp encode_body(%{}, nil), do: ""
  defp encode_body(nil, nil), do: ""
  defp encode_body(provided, from_previous), do: Poison.encode!(provided || from_previous)

  defp decode(%Tesla.Env{body: ""}), do: %Transform{output: ""}

  defp decode(%Tesla.Env{body: body, headers: headers}) do
    json? = Utils.has_content_type?(headers, "application/json")
    output = if json?, do: Poison.decode!(body), else: body

    Transform.new(output: output)
  end

  defp parse_headers(headers), do: Enum.into(headers, [])

  defp parse_method(method) do
    method
    |> String.downcase()
    |> String.to_atom()
  end
end
