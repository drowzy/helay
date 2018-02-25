defmodule HttpReceiverTest do
  use ExUnit.Case
  doctest HttpReceiver

  test "greets the world" do
    assert HttpReceiver.hello() == :world
  end
end
