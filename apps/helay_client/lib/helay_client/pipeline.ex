defmodule HelayClient.Pipeline do
  require Logger
  alias HelayClient.{Transform, Middleware, Middleware.KV}

  def handle(_arg, {endpoint, body}) do
    endpoint
    |> KV.get_or_default(default_transform(endpoint))
    |> Map.get(:transforms)
    |> exec(body)
  end

  def exec(transforms, input) do
    transforms
    |> Transform.activate(input)
    |> Enum.reduce_while(input, &transform/2)
  end

  def dispatch(args) do
    Logger.info("Received dispatch #{args}")
  end

  defp transform(%Transform{} = t, input) do
    log_m = "Transform of type `#{Atom.to_string(t.type)}"

    result =
      t
      |> Map.put(:input, input)
      |> Transform.replace_templates()
      |> Transform.run_with()

    case result do
      {:ok, %Transform{output: output}} ->
        Logger.info("#{log_m} ok: #{inspect(output)}")
        {:cont, output}

      {:error, reason} ->
        Logger.error(
          "#{log_m} failed with: #{reason}.\nargs :: #{inspect(t.args)}\ninput :: #{
            inspect(input)
          }"
        )

        {:halt, reason}
    end
  end

  defp default_transform(endpoint),
    do: %Middleware{transforms: [%Transform{type: :console, args: endpoint}]}
end