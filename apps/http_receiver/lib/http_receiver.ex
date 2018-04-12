defmodule HttpReceiver do
  alias HttpReceiver.Dispatcher
  require Logger

  use Supervisor

  def start_link(mfa, args) do
    Supervisor.start_link(__MODULE__, {mfa, args}, name: __MODULE__)
  end

  def init({mfa, args}) do
    port = Keyword.get(args, :port, 6060)
    url_base = Keyword.get(args, :url_base, "hook")

    Logger.info("Started Hook relay on port #{port}")

    children = [
      {Registry, keys: :duplicate, name: HttpReceiver.Registry},
      %{
        id: :cowboy,
        start: {
          :cowboy,
          :start_clear,
          [:http_listener, [port: port], %{env: %{dispatch: router_config(url_base, mfa)}}]
        }
      }
    ]

    opts = [strategy: :one_for_one, name: HttpReceiver.Supervisor]

    Supervisor.init(children, opts)
  end

  defp router_config(url_base, mfa) do
    :cowboy_router.compile([
      {:_,
       [
         {"/#{url_base}", HttpReceiver.Handler, %{mfa: mfa}}
       ]}
    ])
  end
end
