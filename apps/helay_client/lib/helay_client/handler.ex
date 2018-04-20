defmodule HelayClient.Handler do
  require Logger
  alias HelayClient.{Transform, Settings.KV}

  def handle(_arg, {endpoint, body}) do
    endpoint
    |> KV.get()
    |> Map.get(:transforms)
    |> Transform.activate(body)
    |> Enum.reduce_while(body, &transform/2)
  end

  def dispatch(args) do
    Logger.info("Received dispatch #{args}")
  end

  defp transform(%Transform{} = t, input) do
    result =
      t
      |> Map.put(:input, input)
      |> Transform.run_with()

    case result do
      {:ok, %Transform{output: output}} ->
        {:cont, output}

      {:error, reason} ->
        Logger.error(
          "Transform of type `#{Atom.to_string(t.type)}` failed with: #{reason}.\nargs :: #{
            t.args
          }\ninput :: #{inspect(input)}"
        )

        {:halt, reason}
    end
  end
end
