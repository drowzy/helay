defmodule HelayClient.Handler do
  require Logger
  def make_handler(key, decode?), do: &dispatch(key, &1, decode?)

  def dispatch(key, event, true) do
    data =
      event.message
      |> Poison.decode!()

    do_dispatch(key, data)
  end

  def dispatch(key, event, _decode?), do: do_dispatch(key, event.message)

  defp do_dispatch(key, data) do
    IO.puts("Doing dispatch #{inspect data}")
  end
end
