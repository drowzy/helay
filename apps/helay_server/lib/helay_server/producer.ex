defmodule HelayServer.Producer do
  use GenStage

  def start_link(opts \\ []) do
    GenStage.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    key = Keyword.get(opts, :key)

    {:ok, _pid} = HttpReceiver.register(key, [])

    {:producer, %{demand: 0, events: []}}
  end

  def handle_demand(demand, %{events: events} = state) when demand > 0 do
    {events, new_events} = Enum.split(events, demand)
    pending_demand = demand - length(events)

    {:noreply, events, %{state | events: new_events, demand: pending_demand}}
  end

  def handle_info(
        {:push_event, event},
        %{events: events, demand: demand} = state
      ) do
    {events, new_events} = Enum.split([event | events], demand)

    {:noreply, events, %{state | events: new_events, demand: demand - length(events)}}
  end
end
