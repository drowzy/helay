defmodule HelayClient.Trigger.WorkerSupervisor do
  use DynamicSupervisor

  @registry Trigger.Registry
  alias HelayClient.{Trigger, Trigger.Server}

  def start_link(opts \\ [])

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_child(opts) do
    {name, opts} = Keyword.pop(opts, :name)

    new_opts =
      Keyword.new()
      |> Keyword.put(:id, Trigger.registry_name(Keyword.fetch!(opts, :type), name))
      |> Keyword.put(:registry, @registry)

    spec = {Server, Keyword.merge(opts, new_opts)}

    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
