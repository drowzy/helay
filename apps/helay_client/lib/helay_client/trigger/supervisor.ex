defmodule HelayClient.Trigger.Supervisor do
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    port = Keyword.get(opts, :port, 4001)

    children = [
      {KV, []},
      {Registry, keys: :unique, name: Trigger.Registry},
      {DynamicSupervisor, strategy: :one_for_one, name: Trigger.DynamicSupervisor}
    ]

    opts = [strategy: :one_for_one, name: HelayClient.Supervisor]

    Supervisor.init(children, opts)
  end
end
