defmodule HelayClientTest do
  use ExUnit.Case
  doctest HelayClient

  test "greets the world" do
    assert HelayClient.hello() == :world
  end
end
