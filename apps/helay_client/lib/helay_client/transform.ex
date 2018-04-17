defmodule HelayClient.Transform do
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
    opts = Map.update!(opts, "type", &(String.to_atom(&1)))

    to_struct(__MODULE__, opts)
  end

  def new(opts), do: struct(__MODULE__, opts)

  # https://stackoverflow.com/questions/30927635/in-elixir-how-do-you-initialize-a-struct-with-a-map-variable
  defp to_struct(kind, attrs) do
    struct = struct(kind)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end
end
