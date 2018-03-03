defmodule HelayServer.Hooks.Server do
  use GRPC.Server, service: Helay.HelayHook.Service

  alias GRPC.Server

  @spec receive_hook(Helay.Route.t(), GRPC.Server.Stream.t()) :: any
  def receive_hook(_route, stream) do
    [{HelayServer.Producer, cancel: :transient}]
    |> GenStage.stream()
    |> Stream.map(&Helay.Hook.new(message: Poison.encode!(&1)))
    |> Enum.each(&Server.stream_send(stream, &1))
  end
end
