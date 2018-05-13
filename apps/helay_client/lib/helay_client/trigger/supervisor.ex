defmodule HelayClient.Trigger.Supervisor do
  use Supervisor

  alias HelayClient.{KV, Trigger.Scheduler, Trigger.Cron}

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    children = [
      {KV, name: TriggerKV},
      {Registry, keys: :unique, name: Trigger.Registry},
      {Scheduler, []},
      {Cron, name: Trigger.Cron},
      {HelayClient.Trigger.WorkerSupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: HelayClient.Supervisor]

    Supervisor.init(children, opts)
  end
end
