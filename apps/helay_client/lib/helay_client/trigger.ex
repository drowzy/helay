defmodule HelayClient.Trigger do
  alias HelayClient.Transform

  defmodule Binding do
    defstruct transforms: nil, conditions: []

    def match?(%__MODULE__{transforms: nil}), do: false
    def match?(%__MODULE__{transforms: _m}), do: true
  end

  alias HelayClient.Utils

  defstruct name: nil, description: nil, type: nil, args: nil, bindings: []

  @sup_name Helay.TaskSupervisor

  def new(opts) when is_map(opts) do
    __MODULE__
    |> Utils.to_struct(opts)
    |> Map.update!(:type, &String.to_atom(&1))
  end

  def new(opts), do: struct(__MODULE__, opts)

  def associate(%__MODULE__{} = t, %Binding{} = b, transforms) do
    binding = Map.replace!(b, :transforms, transforms)

    Map.update!(t, :bindings, &([binding | &1]))
  end

  def associate(%__MODULE__{}, binding), do: raise ArgumentError, "#{inspect binding} association not supported."

  def yield(t, input, opts \\ [])
  def yield(%__MODULE__{bindings: []}, _input, _opts), do: {:error, {:nop, "No bindings"}}
  def yield(%__MODULE__{name: name, bindings: bindings}, input, opts) do
    sup_name = Keyword.get(opts, :supervisor_name, @sup_name)

    case Enum.find(bindings, &Binding.match?/1) do
      nil -> {:error, {:not_associated, "Trigger #{name} does not have any associated middlewares"}}
      %Binding{transforms: ts} ->
        sup_name
        |> Task.Supervisor.async(fn -> Transform.apply_to(ts, input) end)
        |> Task.await()
    end
  end
end
