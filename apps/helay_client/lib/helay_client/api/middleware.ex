defmodule HelayClient.API.Middleware do
  use Plug.Router
  require Logger

  alias HelayClient.{Middleware, KV}

  @kv_name MiddlewareKV

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/" do
    body =
      @kv_name
      |> KV.get_all()
      |> encode()

    send_resp(conn, 200, body)
  end

  get "/:id" do
    body =
      @kv_name
      |> KV.get(id)
      |> encode()

    send_resp(conn, 200, body)
  end

  post "/" do
    # Plug.Parsers doesn't work for some reason...
    {:ok, body_params, _conn} = Plug.Conn.read_body(conn)

    {status, data} =
      body_params
      |> Poison.decode!()
      |> Middleware.new()
      |> (&KV.put(@kv_name, &1.id, &1)).()

    send_resp(conn, status, encode(data))
  end

  defp encode(body), do: Poison.encode!(body)
end
