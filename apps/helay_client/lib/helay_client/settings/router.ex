defmodule HelayClient.Settings.Router do
  use Plug.Router

  alias HelayClient.{Settings, Settings.KV, Transform}

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/settings" do
    settings = Settings.get_all()
    send_resp(conn, 200, encode(settings))
  end

  post "/settings" do
    # Plug.Parsers doesn't work for some reason...
    {:ok, body_params, _conn} = Plug.Conn.read_body(conn)

    {status, body} =
      body_params
      |> Poison.decode!()
      |> Settings.new()
      |> KV.put()
      |> case do
        :ok -> {201, %{"message" => "ok"}}
        _ -> {400, %{"message" => "invalid settings"}}
      end

    send_resp(conn, status, encode(body))
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp encode(body), do: Poison.encode!(body)
end
