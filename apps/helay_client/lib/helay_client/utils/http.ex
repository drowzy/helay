defmodule HelayClient.Utils.HTTP do
  use Tesla
  alias HelayClient.Utils

  adapter(Tesla.Adapter.Hackney)

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

  def has_content_type?(headers, content_type) do
    Enum.any?(headers, fn {type, value} ->
      String.downcase(type) == "content-type" and String.downcase(value) == content_type
    end)
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
