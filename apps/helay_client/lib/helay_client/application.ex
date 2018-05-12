defmodule HelayClient.Application do
  use Application
  alias HelayClient.Utils
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, %{settings_port: port}} = Confex.fetch_env(:helay_client, :client)

    children = [
      {HelayClient.Middleware.Supervisor, []},
      {HelayClient.Trigger.Supervisor, []},
      {Plug.Adapters.Cowboy2,
       scheme: :http, plug: HelayClient.API, options: [port: port, timeout: 70_000]},
      {Task.Supervisor, name: Helay.TaskSupervisor}
    ]

    opts = [strategy: :one_for_one, name: HelayClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
