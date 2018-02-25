defmodule HelayServerTest do
  use ExUnit.Case
  doctest HelayServer

  test "greets the world" do
    assert HelayServer.hello() == :world
  end
end
