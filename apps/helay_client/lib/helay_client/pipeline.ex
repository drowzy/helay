defmodule HelayClient.Pipeline do
  require Logger

  alias HelayClient.{
    Middleware,
    Middleware.KV,
    Transform,
    Transform.Jq,
    Transform.Identity,
    Transform.HTTP,
    Transform.File,
    Transform.Parallel
  }

  def handle(_arg, {endpoint, body}) do
    endpoint
    |> KV.get_or_default(default_transform(endpoint))
    |> Map.get(:transforms)
    |> exec(body)
  end

  def exec(transforms, input) do
    res =
      transforms
      |> Transform.activate(input)
      |> Enum.reduce_while(input, &transform/2)

    case res do
      {:error, reason} = err -> err
      output -> {:ok, output}
    end
  end

  defp transform(%Transform{} = t, input) do
    log_m = "Transform of type `#{Atom.to_string(t.type)}"

    result =
      t
      |> Map.put(:input, input)
      |> Transform.replace_templates()
      |> run_with()

    case result do
      {:ok, %Transform{output: output}} ->
        Logger.info("#{log_m} ok: #{inspect(output)}")
        {:cont, output}

      {:error, reason} = err ->
        Logger.error(
          "#{log_m} failed with: #{inspect(reason)}.\nargs :: #{inspect(t.args)}\ninput :: #{inspect(input)}"
        )

        {:halt, err}
    end
  end

  defp default_transform(endpoint), do: %Middleware{transforms: [%Transform{type: :identity, args: endpoint}]}

  def run_with(%Transform{type: :jq} = t), do: Jq.run(t)
  def run_with(%Transform{type: :identity} = t), do: Identity.run(t)
  def run_with(%Transform{type: :http} = t), do: HTTP.run(t)
  def run_with(%Transform{type: :file} = t), do: File.run(t)
  def run_with(%Transform{type: :parallel} = t), do: Parallel.run(t)
  def run_with(%Transform{type: type}), do: {:error, {:not_supported, type}}
end
