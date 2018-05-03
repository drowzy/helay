defmodule HelayClient.Transform.IdentityTest do
  use ExUnit.Case

  alias HelayClient.Transform
  alias HelayClient.Transform.Identity

  setup do
    {:ok, t: %Transform{type: :identity, input: "identity"}}
  end

  @tag :capture_log
  test "run/1 output is the same as input", %{t: %Transform{input: input} = t} do
    assert {:ok, %Transform{output: output}} = Identity.run(t)
    assert output == input
  end
end
