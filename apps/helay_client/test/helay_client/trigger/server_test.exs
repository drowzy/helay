defmodule HelayClient.Trigger.ServerTest do
  use ExUnit.Case

  alias HelayClient.Trigger.{Server, Binding}
  alias HelayClient.{Middleware, Transform}

  setup do
    # state = %State{registry: registry, bindings: bindings, id: id} = struct(State, opts)
    registry_name = ServerTest
    id = "web_hook:foo"
    opts = [
      bindings: [],
      id: id,
      type: :web_hook,
      registry: registry_name
    ]
    {:ok, _pid} = Registry.start_link(keys: :unique, name: registry_name)
    {:ok, pid} = start_supervised({Server, opts})
    {:ok, pid: pid, registry: registry_name, id: id}
  end

  test "should register the process under the given id with bindings as value", %{registry: registry, id: id} do
    assert [{_pid, bindings}] = Registry.lookup(registry, id)
    assert bindings == []
  end

  test "associate creates a between the trigger & middleware", %{pid: pid, registry: registry, id: id} do
    binding = %Binding{}
    middleware = Middleware.new(
      transforms: [Transform.new(type: :identity)]
    )

    result = GenServer.call(pid, {:associate, binding, middleware})
    [{_, bindings}] = Registry.lookup(registry, id)

    assert {:ok, {^binding, ^middleware}} = result
    assert length(bindings) == 1
  end

  test "yield returns :error when there's no associated bindings", %{pid: pid} do
    assert {:error, {:not_associated, _msg}} = GenServer.call(pid, {:yield, %{"foo" => "bar"}})
  end

  @tag :capture_log
  test "yield returns result when there's bindings & middleware assoc", %{pid: pid} do
    binding = %Binding{}
    middleware = Middleware.new(transforms: [Transform.new(type: :identity)])
    input = %{"foo" => "bar"}

    _ = GenServer.call(pid, {:associate, binding, middleware})
    assert {:ok, _} = GenServer.call(pid, {:yield, input})
  end
end
