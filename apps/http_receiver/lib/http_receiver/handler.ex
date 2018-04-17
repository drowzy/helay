defmodule HttpReceiver.Handler do
  require Logger

  alias HttpReceiver.Handler.Helpers

  def init(req, state), do: handle(req, state)

  def handle(%{method: "POST"} = req, %{mfa: mfa} = state) do
    {body, _req} = Helpers.decode_body(req)
    {path, _req} = Helpers.request_path(req)
    {mod, fun, args} = mfa

    Logger.info("Hook triggered #{path}")

    {:ok, _pid} = Task.start(mod, fun, args ++ [{path, body}])

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
