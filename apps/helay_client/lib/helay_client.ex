defmodule HelayClient do
  alias HelayClient.Utils

  def child_spec(mode, conf) when is_binary(mode), do: child_spec(String.to_atom(mode), conf)

  def child_spec(:mixed, %{receiver_port: port}) do
    [
      %{
        id: HelayClient.HttpReceiver,
        start:
          {HttpReceiver, :start_link,
           [
             {HelayClient.Handler, :handle, ["foo"]},
             [port: Utils.parse_port(port), url_base: "hook"]
           ]}
      }
    ]
  end

  def child_spec(_, _conf) do
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
end
