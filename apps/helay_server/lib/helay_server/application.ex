defmodule HelayServer.Application do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(HttpReceiver, [{HelayServer.Producer, :push_event, [HelayServer.Producer]}, [port: 4400, url_base: "hook"]]),
      worker(HelayServer.Producer, []),
      supervisor(GRPC.Server.Supervisor, [{HelayServer.Hooks.Server, 50051}])
    ]

    opts = [strategy: :one_for_one, name: HelayServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
