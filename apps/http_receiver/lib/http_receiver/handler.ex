defmodule HttpReceiver.Handler do
  require Logger

  alias HttpReceiver.Handler.Helpers

  def init(req, state), do: handle(req, state)

  def handle(%{method: "POST"} = req, %{cb: dispatch, key: key} = state) do
    {body, req} = Helpers.decode_body(req)

    Logger.info("Hook triggered #{:cowboy_req.uri(req)}")

    _ = dispatch.(key, :push_event, body)
    {result, req} = respond(req, 200, %{"message" => "ok"})
    {result, req, state}
  end

  def handle(req, state) do
    Logger.info("Received unsupported method #{:cowboy_req.method(req)} -> #{inspect(:cowboy_req.headers(req))}")

    {result, req} =
      respond(req, 418, %{
        "error" => "action #{:cowboy_req.method(req)} not supported"
      })

    {result, req, state}
  end

  defp respond(req, status, body) do
    req
    |> Helpers.set_headers(content_type())
    |> Helpers.set_body(body)
    |> Helpers.respond(status)
  end

  defp content_type, do: %{"Content-type" => "application/json"}
end
