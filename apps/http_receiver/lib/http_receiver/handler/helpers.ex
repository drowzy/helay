defmodule HttpReceiver.Handler.Helpers do
  def set_body(req, body) do
    body = Poison.encode!(body)
    :cowboy_req.set_resp_body(body, req)
  end

  def set_headers(req, headers \\ %{}), do: :cowboy_req.set_resp_headers(headers, req)

  def decode_body(req) do
    {:ok, body, req} = :cowboy_req.read_body(req)
    {do_decode_body(body), req}
  end

  def request_path(req), do: {:cowboy_req.path(req), req}

  defp do_decode_body(body) do
    case Poison.decode(body) do
      {:ok, decoded_value} ->
        decoded_value

      _ ->
        %{}
    end
  end

  def respond(req, status_code, result \\ :ok) do
    req = :cowboy_req.reply(status_code, req)
    {result, req}
  end
end
