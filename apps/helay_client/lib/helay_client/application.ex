defmodule HelayClient.Application do
  use Application
  alias Plug.Adapters.Cowboy2
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, %{mode: mode} = conf} = Confex.fetch_env(:helay_client, :client)

    children =
      [
        {HelayClient.Settings, []},
        {Plug.Adapters.Cowboy2,
         scheme: :http, plug: HelayClient.Settings.Router, options: [port: 3030, timeout: 70_000]}
      ] ++ children_by_mode(mode, conf)

    opts = [strategy: :one_for_one, name: HelayClient.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp children_by_mode(mode, conf) when is_binary(mode), do: children_by_mode(String.to_atom(mode), conf)

  defp children_by_mode(:mixed, %{receiver_port: port}) do
    port = if Kernel.is_integer(port), do: port, else: String.to_integer(port)

    [
      %{
        id: HelayClient.HttpReceiver,
        start: {HttpReceiver, :start_link, [{HelayClient.Handler, :handle, ["foo"]}, [port: port, url_base: "hook"]]}
      }
    ]
  end

  defp children_by_mode(_, _conf) do
    {:ok, %{url: server_url, provider: provider}} = Confex.fetch_env(:helay_client, :server)
    {:ok, channel} = GRPC.Stub.connect(server_url, [])

    [
      Supervisor.Spec.worker(HelayClient.Consumer, [
        [
          channel: channel,
          dispatcher: &HelayClient.Handler.dispatch/1,
          provider: provider
        ]
      ])
    ]
  end

  defp router_config(mod) do
    :cowboy_router.compile([
      {:_,
       [
         {"/settings", HelayClient.HTTPHandler, mod}
       ]}
    ])
  end
end
