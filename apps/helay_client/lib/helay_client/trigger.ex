defmodule HelayClient.Trigger do
  @registry Trigger.Registry
  @trigger_supervisor Trigger.DynamicSupervisor

  defmodule Binding do
    defstruct conditions: []
    def match?(%__MODULE__{}, _input), do: true
  end

  def associate(name, binding, middleware) do
    with {:ok, pid, _value} <- lookup(name),
         {:ok, _assoc} = res <- GenServer.call(pid, {:associate, binding, middleware}) do
      res
    else
      error -> error
    end
  end

  def yield(name, input) do
    case lookup(name) do
      {:ok, pid, _value} -> GenServer.call(pid, {:yield, input})
      err -> err
    end
  end

  defp lookup(name) do
    id = registry_name(name)

    case Registry.lookup(@registry, id) do
      [] -> {:error, :not_found}
      [{pid, bindings}] -> {:ok, pid, bindings}
    end
  end

  defp registry_name({type, name}), do: "#{Atom.to_string(type)}:#{name}"
end
