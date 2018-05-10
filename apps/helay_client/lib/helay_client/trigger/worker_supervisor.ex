defmodule HelayClient.Trigger.WorkerSupervisor do
  use DynamicSupervisor

  alias HelayClient.Trigger.Worker

  @registry_name Trigger.Registry

  def start_link(opts \\ [])

  def start_link(opts) do
    DynamicSupervisor.start_link(__MODULE__, opts, opts)
  end

  def init(opts \\ [])

  def init(_opts) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_proc(pid, opts) do
    name = Keyword.fetch(opts, :name)
    spec = {Worker, opts}

    case DynamicSupervisor.start_child(pid, spec) do
      {:ok, _pid} -> {:ok, name}
      {:error, {:already_started, _pid}} = err -> err
      error -> error
    end
  end

  def exists?(id) do
    case Registry.lookup(@registry_name, id) do
      [] -> false
      _ -> true
    end
  end

  def find(id) do
    case Registry.lookup(@registry_name, id) do
      [] -> {:error, :not_found}
      [{pid, _}] -> {:ok, pid}
    end
  end

  def via_tuple(middleware_id) do
    {:via, Registry, {@registry_name, middleware_id}}
  end
end
