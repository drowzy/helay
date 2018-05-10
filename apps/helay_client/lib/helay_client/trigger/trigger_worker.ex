defmodule HelayClient.Trigger.Worker do
  use GenServer

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    {:ok, %{}}
  end

  def associate(pid, binding, transforms) do
    GenServer.call(pid, {:associate, binding, transforms})
  end

  def handle_call({:associate, binding, transforms}, _from, state) do
    binding = Map.replace!(binding, :transforms, transforms)
    Map.update!(transforms, :bindings, &([binding | &1]))
  end
end
