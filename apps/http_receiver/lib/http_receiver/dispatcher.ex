defmodule HttpReceiver.Dispatcher do
  def register(key, args), do: Registry.register(HttpReceiver.Registry, key, args)

  def dispatch(key, type, event) do
    Registry.dispatch(HttpReceiver.Registry, key, fn entries ->
      for {pid, _} <- entries, do: send(pid, {type, event})
    end)
  end
end
