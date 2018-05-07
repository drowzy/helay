defmodule HelayClient.Transform do
  alias HelayClient.{Utils, Template}

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

  defp new_many(transforms), do: Enum.map(transforms, &new(&1))
end
