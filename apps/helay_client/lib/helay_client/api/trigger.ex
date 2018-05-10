defmodule HelayClient.API.Trigger do
  use Plug.Router
  require Logger

  plug(:match)
  plug(:dispatch)

  get "/" do
    send_resp(conn, :ok, encode(%{message: "/triggers"}))
  end

  post "/" do
    # Plug.Parsers doesn't work for some reason...
    send_resp(conn, :ok, encode(%{message: "/triggers/:id/bindings"}))
  end

  post "/:id/bindings" do
    send_resp(conn, :ok, encode(%{message: "/triggers/:id/bindings"}))
  end

  defp encode(body), do: Poison.encode!(body)
end
