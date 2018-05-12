defmodule HelayClient.Transform do
  require Logger

  alias HelayClient.{
    Utils,
    Template,
    Transform.Jq,
    Transform.Identity,
    Transform.HTTP,
    Transform.File,
    Transform.Parallel
  }

  @derive {Poison.Encoder, only: [:args, :type]}
  defstruct type: nil, args: nil, input: nil, output: nil

  @type t :: %__MODULE__{
          type: :jq | nil,
          args: term(),
          input: map(),
          output: map() | nil
        }

  def activate(%__MODULE__{} = t, input), do: activate([t], input)

  def activate([%__MODULE__{} = h | t], input) do
    [Map.put(h, :input, input) | t]
  end

  def new(%{"type" => "parallel"} = opts) do
    __MODULE__
    |> Utils.to_struct(opts)
    |> Map.update!(:type, &String.to_atom/1)
    |> Map.update!(:args, fn ts -> Enum.map(ts, &new_many/1) end)
  end

  def new(opts) when is_map(opts) do
    __MODULE__
    |> Utils.to_struct(opts)
    |> Map.update!(:type, &String.to_atom(&1))
  end

  def new(opts), do: struct(__MODULE__, opts)

  def replace_templates(%__MODULE__{args: args, input: input} = t) when is_binary(args),
    do: %{t | args: Template.substitue(args, input)}

  def replace_templates(%__MODULE__{args: args, input: input} = t) when is_map(args) do
    new_args =
      args
      |> Template.substitue(input)
      |> (&Map.merge(args, &1)).()

    %{t | args: new_args}
  end

  def replace_templates(t), do: t

  def apply_to(transforms, input) do
    res =
      transforms
      |> activate(input)
      |> Enum.reduce_while(input, &transform/2)

    case res do
      {:error, reason} = err -> err
      output -> {:ok, output}
    end
  end

  def apply_with(%__MODULE__{type: :jq} = t), do: Jq.run(t)
  def apply_with(%__MODULE__{type: :identity} = t), do: Identity.run(t)
  def apply_with(%__MODULE__{type: :http} = t), do: HTTP.run(t)
  def apply_with(%__MODULE__{type: :parallel} = t), do: Parallel.run(t)
  def apply_with(%__MODULE__{type: type}), do: {:error, {:not_supported, type}}

  defp transform(%__MODULE__{} = t, input) do
    log_m = "Transform of type `#{Atom.to_string(t.type)}"

    result =
      t
      |> Map.put(:input, input)
      |> replace_templates()
      |> apply_with()

    case result do
      {:ok, %__MODULE__{output: output}} ->
        Logger.info("#{log_m} ok: #{inspect(output)}")
        {:cont, output}

      {:error, reason} = err ->
        Logger.error(
          "#{log_m} failed with: #{inspect(reason)}.\nargs :: #{inspect(t.args)}\ninput :: #{
            inspect(input)
          }"
        )

        {:halt, err}
    end
  end

  defp new_many(transforms), do: Enum.map(transforms, &new(&1))
end
