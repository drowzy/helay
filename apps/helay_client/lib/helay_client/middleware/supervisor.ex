defmodule HelayClient.Middleware.Supervisor do
  alias HelayClient.KV
  use Supervisor

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def init(opts) do
    children = [
      {KV, name: MiddlewareKV},
    ]

    opts = [strategy: :one_for_one, name: Middleware.Supervisor]

    Supervisor.init(children, opts)
  end
end
