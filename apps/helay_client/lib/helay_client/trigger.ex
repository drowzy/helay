defmodule HelayClient.Trigger do
  alias HelayClient.{Utils, Binding}

  defstruct name: nil, description: nil, type: nil, args: nil, bindings: []

  def new(opts) when is_map(opts) do
    __MODULE__
    |> Utils.to_struct(opts)
    |> Map.update!(:type, &String.to_atom(&1))
  end

  def new(opts), do: struct(__MODULE__, opts)

  def associate(%__MODULE__{} = t, %Binding{} = b), do: Map.update!(t, :bindings, &([b | &1]))
  def associate(%__MODULE__{}, binding),do: raise ArgumentError, "#{inspect binding} association not supported."
end
