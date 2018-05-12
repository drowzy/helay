defmodule HelayClient.Trigger.Server do
  use GenServer

  alias HelayClient.{Transform, Middleware, Trigger.Binding}

  defmodule State do
    @sup_name Helay.TaskSupervisor
    @enforce_keys [:registry, :id, :type]
    defstruct registry: nil,
              task_supervisor: @sup_name,
              id: nil,
              type: nil,
              args: nil,
              bindings: []
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    state = %State{registry: registry, bindings: bindings, id: id} = struct(State, opts)
    {:ok, _pid} = Registry.register(registry, id, bindings)
    {:ok, state}
  end

  def handle_call(
        {:associate, binding, middleware},
        _from,
        %State{registry: registry, id: id} = state
      ) do
    assoc_t = {binding, middleware}
    {bindings, _prev} = Registry.update_value(registry, id, &[assoc_t | &1])

    {:reply, {:ok, assoc_t}, %State{state | bindings: bindings}}
  end

  def handle_call({:yield, input}, _from, %State{bindings: [], id: id} = state),
    do: {:reply, no_assoc(id), state}

  def handle_call(
        {:yield, input},
        _from,
        %State{bindings: bindings, id: id, task_supervisor: sup_name} = state
      ) do
    reply =
      case Enum.find(bindings, fn {b, _ts} -> Binding.match?(b, input) end) do
        nil ->
          no_assoc(id)

        {_binding, %Middleware{transforms: ts}} ->
          sup_name
          |> Task.Supervisor.async(fn -> Transform.apply_to(ts, input) end)
          |> Task.await()
      end

    {:reply, reply, state}
  end

  defp no_assoc(id),
    do: {:error, {:not_associated, "Trigger #{id} does not have any associated middlewares"}}
end
