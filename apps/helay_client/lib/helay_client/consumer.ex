defmodule HelayClient.Consumer do
  use GenServer
  require Logger

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    channel = Keyword.get(opts, :channel, nil)
    provider = Keyword.get(opts, :provider, nil)
    dispatcher = Keyword.get(opts, :dispatcher, fn args -> args end)

    Process.send_after(self(), {:consume_hook, provider}, 0)

    {:ok,
     %{
       channel: channel,
       dispatcher: dispatcher
     }}
  end

  def handle_info({:consume_hook, provider}, %{channel: channel, dispatcher: dispatcher} = state) do
    Logger.info("Recv on channel #{inspect(channel)} with #{provider}")
    :ok = recv(channel, Helay.Route.new(provider: provider), dispatcher)

    {:noreply, state}
  end

  defp recv(channel, req, dispatcher) do
    channel
    |> Helay.HelayHook.Stub.receive_hook(req)
    |> Task.async_stream(&dispatcher.(&1))
    |> Stream.run()
  end
end
