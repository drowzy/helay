defmodule HelayClient.Transform.HTTP do
  @behaviour HelayClient.Transform
  import Logger

  use Tesla
  adapter(Tesla.Adapter.Hackney)

  alias HelayClient.Transform

  def run(%Transform{type: :http, args: args, input: input}) do
    http_client = client(args)

    case http_client.(input) do
      {:ok, response} ->
        Logger.info("Http transforms returned #{inspect(response)} #{response.status}")
        # TODO might want to check resp headers
        {:ok, %Transform{output: Poison.decode!(response.body)}}

      {:error, reason} = error ->
        Logger.error("Http transforms returned error #{inspect(reason)}")
        error
    end
  end

  def client(args) do
    method = parse_method(args["method"])
    headers = parse_headers(args["headers"])
    uri = args["uri"]
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
  defp parse_headers(headers), do: Enum.into(headers, [])

  defp parse_method(method) do
    method
    |> String.downcase()
    |> String.to_atom()
  end
end
