defmodule HelayClient.Middleware.Router do
  use Plug.Router
  require Logger

  alias HelayClient.{Pipeline, Middleware, Middleware.KV, Transform}

  plug(Plug.Logger)
  plug(:match)
  plug(:dispatch)

  get "/middlewares" do
    settings = Middleware.KV.get_all()
    send_resp(conn, 200, encode(settings))
  end

  post "/middlewares" do
    # Plug.Parsers doesn't work for some reason...
    {:ok, body_params, _conn} = Plug.Conn.read_body(conn)

    {status, body} =
      case start_proc(body_params) do
        {:ok, mid} -> {:created, mid}
        {:error, reason} -> {:internal_server_error, %{"message" => "#{inspect(reason)}"}}
      end

    send_resp(conn, status, encode(body))
  end

  get "/middlewares/:id/metrics" do
    {:ok, pid} = HelayClient.Middleware.WorkerSupervisor.find(id)
    {:ok, count} = HelayClient.Middleware.Worker.count(pid)

    send_resp(conn, 200, encode(count))
  end

  post "/middlewares/:id" do
    {status, body} =
      with {:ok, body_params, _conn} <- Plug.Conn.read_body(conn),
           {:ok, pid} <- HelayClient.Middleware.WorkerSupervisor.find(id),
           :ok <- HelayClient.Middleware.Worker.exec(pid, Poison.decode!(body_params)) do
        {:ok, %{"message" => "ok"}}
      else
        err -> {:internal_server_error, %{"message" => "#{inspect(err)}"}}
      end

    send_resp(conn, status, encode(body))
  end

  match _ do
    send_resp(conn, 404, "oops")
  end

  defp encode(body), do: Poison.encode!(body)

  defp start_proc(data) do
    mid_res =
      data
      |> Poison.decode!()
      |> Middleware.new()
      |> KV.put()

    with {:ok, %Middleware{id: id, transforms: ts} = middleware} <- mid_res,
         {:ok, name} <-
           HelayClient.Middleware.WorkerSupervisor.start_proc(
             MiddlewareWorkerSupervisor,
             id,
             mfa: {Pipeline, :exec, [ts]}
           ) do
      Logger.info("Middleware #{name} #{inspect(ts)} started")
      {:ok, middleware}
    else
      err ->
        Logger.error("Middleware #{data} failed to start #{inspect(err)}")
        err
    end
  end
end
