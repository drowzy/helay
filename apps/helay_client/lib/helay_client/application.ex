defmodule HelayClient.Application do
  use Application
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, %{mode: mode} = conf} = Confex.fetch_env(:helay_client, :client)

    children = children_by_mode(mode, conf)

    opts = [strategy: :one_for_one, name: HelayClient.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp children_by_mode(mode, conf) when is_binary(mode), do: children_by_mode(String.to_atom(mode), conf)

  defp children_by_mode(:mixed, %{receiver_port: port}) do
    port = if Kernel.is_integer(port), do: port, else: String.to_integer(port)
    dispatch_key = "registry_push"

    [
      Supervisor.Spec.supervisor(HttpReceiver, [[port: port, url_base: "hook", key: dispatch_key]]),
      Supervisor.Spec.worker(HelayClient.Receiver, [
        [key: dispatch_key, dispatcher: HelayClient.Handler.make_handler("key", false)]
      ])
    ]
  end

  defp children_by_mode(_, _conf) do
    {:ok, %{url: server_url, provider: provider}} = Confex.fetch_env(:helay_client, :server)
    {:ok, channel} = GRPC.Stub.connect(server_url, [])

    [
      Supervisor.Spec.worker(HelayClient.Consumer, [
        [
          channel: channel,
          dispatcher: HelayClient.Handler.make_handler("key", true),
          provider: provider
        ]
      ])
    ]
  end
end
