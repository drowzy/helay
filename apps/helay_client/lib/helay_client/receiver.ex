defmodule HelayClient.Receiver do
  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    key = Keyword.get(opts, :key)
    dispatcher = Keyword.get(opts, :dispatcher)

    {:ok, _pid} = HttpReceiver.register(key, [])

    {:ok, %{key: key, dispatcher: dispatcher}}
  end

  def handle_info({:push_event, event}, %{dispatcher: dispatch} = state) do
    _res = dispatch.(%{message: event})
    {:noreply, state}
  end
end
