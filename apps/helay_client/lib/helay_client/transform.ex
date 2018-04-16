defmodule HelayClient.Transform do
  defstruct type: nil, args: nil, input: nil, output: nil

  @type t :: %__MODULE__{
          type: :jq | nil,
          args: term(),
          input: map(),
          output: map() | nil
        }

  @callback run(t()) :: {:ok, t()} | {:error, term()}

  @spec pipe(t(), term()) :: t()
  def pipe(%__MODULE__{output: output} = t, args) do
    t
    |> Map.replace!(:args, args)
    |> Map.put(:input, output)
    |> Map.put(:output, nil)
  end

  def new(opts) when is_map(opts), do: to_struct(__MODULE__, opts)
  def new(opts), do: struct(__MODULE__, opts)

  # https://stackoverflow.com/questions/30927635/in-elixir-how-do-you-initialize-a-struct-with-a-map-variable
  defp to_struct(kind, attrs) do
    struct = struct(kind)
    Enum.reduce Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end
  end
end
