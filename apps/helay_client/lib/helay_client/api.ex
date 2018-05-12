defmodule HelayClient.API do
  use Plug.Router
  require Logger

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  forward "/middlewares", to: HelayClient.API.Middleware
  forward "/triggers", to: HelayClient.API.Trigger

  match _ do
    send_resp(conn, 404, "oops")
  end
end
