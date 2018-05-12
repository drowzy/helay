defmodule HelayClient.API.Trigger do
  use Plug.Router
  require Logger

  alias HelayClient.{Trigger, Trigger.Binding, KV}

  @kv_name TriggerKV
  @middleware_kv MiddlewareKV

  plug(:match)
  plug(:dispatch)

  get "/" do
    body =
      @kv_name
      |> KV.get_all()
      |> encode()

    send_resp(conn, 200, body)
  end

  get "/:name" do
    body =
      @kv_name
      |> KV.get(name)
      |> encode()

    send_resp(conn, 200, body)
  end

  post "/" do
    {:ok, body_params, _conn} = Plug.Conn.read_body(conn)

    {status, data} =
      body_params
      |> Poison.decode!()
      |> Trigger.new()
      |> (&KV.put(@kv_name, &1.name, &1)).()

    {:ok, _pid} = HelayClient.Trigger.WorkerSupervisor.start_child(Map.to_list(data))

    send_resp(conn, 201, encode(data))
  end

  post "/:id" do
    {:ok, body_params, _conn} = Plug.Conn.read_body(conn)

    {status, res} =
      @kv_name
      |> KV.get(id)
      |> Trigger.yield(Poison.decode!(body_params))

    send_resp(conn, :ok, encode(%{"status" => inspect(status), "data" => res}))
  end

  post "/:id/bindings" do
    {:ok, body_params, _conn} = Plug.Conn.read_body(conn)
    %{"conditions" => conditions, "middleware_id" => middleware_id} = Poison.decode!(body_params)
    middleware = KV.get(@middleware_kv, middleware_id)
    trigger = KV.get(@kv_name, id)

    {:ok, {b, m}} = Trigger.associate(trigger, %Binding{conditions: conditions}, middleware)

    send_resp(conn, :ok, encode(%{"binding" => b, "middleware" => m}))
  end

  delete "/:id/bindings/:transform_id" do
    send_resp(conn, 204, encode(%{message: "/triggers/:id/bindings"}))
  end

  defp encode(body), do: Poison.encode!(body)
end
