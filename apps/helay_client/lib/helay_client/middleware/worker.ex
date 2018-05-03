defmodule HelayClient.Middleware.Worker do
  use GenServer
  require Logger

  defmodule State do
    defstruct mfa: nil,
              total_count: 0,
              error_count: 0,
              success_count: 0,
              pending: []

    def new(opts) when is_tuple(opts), do: new(mfa: opts)
    def new(opts), do: struct(__MODULE__, opts)
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    state =
      opts
      |> Keyword.fetch!(:mfa)
      |> State.new()

    {:ok, state}
  end

  def count(pid), do: GenServer.call(pid, :count)

  def exec_async(pid, input), do: GenServer.cast(pid, {:exec, input})

  def exec(pid, input), do: GenServer.call(pid, {:exec, input})

  def pending?(pid, ref), do: GenServer.call(pid, {:pending, ref})

  def handle_call(:count, _from, %State{} = state) do
    count = Map.take(state, [:success_count, :error_count, :total_count])

    {:reply, {:ok, count}, state}
  end

  def handle_call({:exec, input}, from, state) do
    {ref, new_state} = run(input, from, state)

    {:reply, {:ok, ref}, new_state}
  end

  def handle_call({:pending, ref}, _from, %State{pending: pending} = state) do
    pending? = Enum.any?(pending, fn {task_ref, _} -> task_ref == ref end)

    {:reply, pending?, state}
  end

  def handle_cast({:exec, input}, state) do
    {_ref, new_state} = run(input, nil, state)

    {:noreply, new_state}
  end

  def handle_info({ref, result}, %State{} = state) when is_reference(ref) do
    key =
      case result do
        {:ok, _task_res} -> :success_count
        {:error, _reason} -> :error_count
        :error -> :error_count
      end

    new_state =
      state
      |> Map.update!(key, &(&1 + 1))
      |> Map.update!(:total_count, &(&1 + 1))
      |> Map.update!(:pending, &Enum.filter(&1, fn {task_ref, _from} -> ref != task_ref end))

    {:noreply, new_state}
  end

  def handle_info({:DOWN, _ref, _, _, reason}, state) when reason == :normal do
    {:noreply, state}
  end

  def handle_info({:DOWN, ref, _, _, _reason}, state) do
    %State{
      total_count: total,
      error_count: errors,
      pending: pending
    } = state

    {:noreply,
     %{
       state
       | total_count: total + 1,
         error_count: errors + 1,
         pending: Enum.filter(pending, fn {task_ref, _from} -> task_ref != ref end)
     }}
  end

  defp run(input, from, %State{mfa: mfa, pending: pending} = s) do
    {mod, fun, args} = mfa

    %Task{ref: ref} =
      Task.Supervisor.async_nolink(Middleware.TaskSupervisor, fn ->
        apply(mod, fun, args ++ [input])
      end)

    {ref, %{s | pending: [{ref, from} | pending]}}
  end
end
