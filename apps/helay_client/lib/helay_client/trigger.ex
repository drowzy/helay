defmodule HelayClient.Trigger do
  alias HelayClient.Utils

  @registry Trigger.Registry
  @cron Trigger.Cron

  defmodule Binding do
    defstruct conditions: []
    def match?(%__MODULE__{}, _input), do: true
  end

  defstruct name: nil, description: nil, type: nil, args: nil, bindings: []

  def new(opts) when is_map(opts) do
    __MODULE__
    |> Utils.to_struct(opts)
    |> Map.put(:id, UUID.uuid4())
    |> Map.update!(:type, &String.to_atom(&1))
  end

  def new(opts), do: __MODULE__ |> struct(opts) |> Map.put(:id, UUID.uuid4())

  def start_link(%__MODULE__{type: :cron} = opts) do
    with {:ok, pid} <- HelayClient.Trigger.WorkerSupervisor.start_child(Map.to_list(opts)),
         {:ok, _job} <- HelayClient.Trigger.Cron.add_job(@cron, opts) do
      IO.puts("STARTED CRON MAN")
      {:ok, pid}
    else
      err -> err
    end
  end

  def start_link(opts) when is_map(opts) do
    HelayClient.Trigger.WorkerSupervisor.start_child(Map.to_list(opts))
  end

  def associate(%__MODULE__{type: type, name: name}, binding, middleware) do
    with {:ok, pid, _value} <- lookup(type, name),
         {:ok, _assoc} = res <- GenServer.call(pid, {:associate, binding, middleware}) do
      res
    else
      error -> error
    end
  end

  def yield(%__MODULE__{type: type, name: name}, input) do
    case lookup(type, name) do
      {:ok, pid, _value} -> GenServer.call(pid, {:yield, input})
      err -> err
    end
  end

  defp lookup(type, name) do
    id = registry_name(type, name)

    case Registry.lookup(@registry, id) do
      [] -> {:error, :not_found}
      [{pid, bindings}] -> {:ok, pid, bindings}
    end
  end

  def registry_name(type, name), do: "#{Atom.to_string(type)}:#{name}"
end
