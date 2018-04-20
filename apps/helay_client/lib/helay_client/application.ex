defmodule HelayClient.Application do
  use Application
  alias HelayClient.Utils
  require Logger

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, %{mode: mode, settings_port: port} = conf} = Confex.fetch_env(:helay_client, :client)

    children =
      [
        {HelayClient.Settings.Supervisor, port: Utils.parse_port(port)}
      ] ++ HelayClient.child_spec(mode, conf)

    opts = [strategy: :one_for_one, name: HelayClient.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
