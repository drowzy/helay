defmodule HelayClient.Transform do
  defstruct args: nil, input: nil, output: nil

  @type t :: %__MODULE__{
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
end
