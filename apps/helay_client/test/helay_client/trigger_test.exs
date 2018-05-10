defmodule HelayClient.TriggerTest do
  use ExUnit.Case

  alias HelayClient.{Trigger, Trigger.Binding}

  test "new/1 with a valid string map returns a trigger struct" do
    assert %Trigger{type: :hook} = Trigger.new(%{"type" => "hook"})
  end

  test "new/1 with a valid keyword list returns a trigger struct" do
    assert %Trigger{type: :hook} = Trigger.new(type: :hook)
  end

  test "can associate a binding to a trigger" do
    binding = %Binding{}
    transforms = []

    [h | _t] =
      [type: :hook]
      |> Trigger.new()
      |> Trigger.associate(binding, transforms)
      |> Map.get(:bindings)

    assert h
    assert h.transforms == transforms
  end
end
