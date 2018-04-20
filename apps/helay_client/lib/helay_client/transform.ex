defmodule HelayClient.Transform do
  alias HelayClient.Utils
  @derive {Poison.Encoder, only: [:args, :type]}
  defstruct type: nil, args: nil, input: nil, output: nil

  @type t :: %__MODULE__{
          type: :jq | nil,
          args: term(),
          input: map(),
          output: map() | nil
        }

  @callback run(t()) :: {:ok, t()} | {:error, term()}

  def activate([%__MODULE__{} = h | t], input) do
    [Map.put(h, :input, input) | t]
  end

  def new(opts) when is_map(opts) do
    opts = Map.update!(opts, "type", &String.to_atom(&1))

    Utils.to_struct(__MODULE__, opts)
  end

  def new(opts), do: struct(__MODULE__, opts)

  def run_with(%__MODULE__{type: :jq} = t), do: Transform.Jq.run(t)
  def run_with(%__MODULE__{type: type}), do: {:error, {:not_supported, type}}
end
