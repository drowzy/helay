defmodule HelayClient.Middleware.Supervisor do
  alias HelayClient.Middleware.{KV, Router, WorkerSupervisor}
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    port = Keyword.get(opts, :port, 4001)

    children = [
      {KV, []},
      {Plug.Adapters.Cowboy2, scheme: :http, plug: Router, options: [port: port, timeout: 70_000]},
      {Registry, keys: :unique, name: Middleware.Registry},
      {WorkerSupervisor, name: MiddlewareWorkerSupervisor},
      {Task.Supervisor, name: Middleware.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: HelayClient.Supervisor]

    Supervisor.init(children, opts)
  end
end
