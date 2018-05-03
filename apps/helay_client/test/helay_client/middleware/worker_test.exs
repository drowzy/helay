defmodule HelayClient.Middleware.WorkerTest do
  use ExUnit.Case

  alias HelayClient.Middleware.Worker

  setup do
    opts = [mfa: {Keyword, :fetch, [[value: 1]]}]

    {:ok, pid} = start_supervised({Worker, opts})
    {:ok, pid: pid}
  end

  test "can return the different counts", %{pid: pid} do
    assert {:ok, 0} = Worker.count(pid, :total)
    assert {:ok, 0} = Worker.count(pid, :success)
    assert {:ok, 0} = Worker.count(pid, :error)
  end

  test "increments total & success counts when result is ok", %{pid: pid} do
    :ok = Worker.exec_async(pid, :value)
    # TODO
    Process.sleep(20)

    assert {:ok, 1} = Worker.count(pid, :total)
    assert {:ok, 1} = Worker.count(pid, :success)
  end

  test "{:error, reason} increments the error_count", %{pid: pid} do
    :ok = Worker.exec_async(pid, :unknown_value)
    # TODO
    Process.sleep(20)

    assert {:ok, 1} = Worker.count(pid, :total)
    assert {:ok, 1} = Worker.count(pid, :error)
  end

  @tag :capture_log
  test "any crash increments the error_count" do
    {:ok, pid} = Worker.start_link(mfa: {Kernel, :raise, []})
    :ok = Worker.exec_async(pid, "err")

    Process.sleep(20)

    assert {:ok, 1} = Worker.count(pid, :total)
    assert {:ok, 1} = Worker.count(pid, :error)
  end
end
