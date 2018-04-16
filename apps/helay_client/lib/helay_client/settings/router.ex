defmodule HelayClient.Settings.Router do
  use Plug.Router

  alias HelayClient.{Settings, Transform}

  plug Plug.Parsers, parsers: [:urlencoded, :json], pass: ["text/*"], json_decoder: Poison
  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/settings" do
    settings = Settings.get_all()
    send_resp(conn, 200, encode(settings))
  end

  post "/settings" do
    {:ok, body_params, _conn} = Plug.Conn.read_body(conn) # Plug.Parsers doesn't work for some reason...
    {status, body} =
      case create_pipeline(Poison.decode!(body_params)) do
        {:ok, resp} -> {201, resp}
        _ -> {400, %{"message" => "invalid settings"}}
      end

    send_resp(conn, status, encode(body))
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp encode(body), do: Poison.encode!(body)
  defp create_pipeline(%{"endpoint" => endpoint, "transforms" => transforms} = req) do
    pipeline = Enum.map(transforms, &Transform.new/1)
    res = Settings.put(endpoint, pipeline)

    {res, req}
  end

  defp create_pipeline(req), do: :error
end
