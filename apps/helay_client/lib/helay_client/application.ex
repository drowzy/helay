defmodule HelayClient.Application do
  use Application
  alias HelayClient.Utils
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, %{settings_port: port, receiver_port: r_port}} =
      Confex.fetch_env(:helay_client, :client)

    children = [
      {HelayClient.Middleware.Supervisor, port: Utils.parse_port(port)},
      %{
        id: HelayClient.HttpReceiver,
        start:
          {HttpReceiver, :start_link,
           [
             {HelayClient.Pipeline, :handle, ["foo"]},
             [port: Utils.parse_port(r_port), url_base: "hook"]
           ]}
      }
    ]

    opts = [strategy: :one_for_one, name: HelayClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
