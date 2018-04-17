defmodule HelayClient.Handler do
  require Logger
  alias HelayClient.{Transform, Settings}

  def handle(_arg, {endpoint, body}) do
    endpoint
    |> Settings.get()
    |> Transform.activate(body)
    |> Enum.reduce(body, &transform/2)
    |> Enum.each(&Logger.info("Transform #{inspect(&1)}"))
  end

  def dispatch(args) do
    Logger.info("Received dispatch #{args}")
  end

  defp transform(%Transform{} = t, input) do
    %Transform{output: output} =
      t
      |> Map.put(:input, input)
      |> run_with()

    output
  end

  defp run_with(%Transform{type: :jq} = t), do: Transform.Jq.run(t)
end
