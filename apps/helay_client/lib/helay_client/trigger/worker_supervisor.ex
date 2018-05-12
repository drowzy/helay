defmodule HelayClient.Trigger.WorkerSupervisor do
  use DynamicSupervisor

  alias HelayClient.Trigger.Server

  def start_link(opts \\ [])
  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts \\ [])
  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(pid, opts) do
    spec = {Server, opts}

    DynamicSupervisor.start_child(pid, spec)
  end
end
