defmodule HelayClient.Middleware.WorkerTest do
  use ExUnit.Case

  alias HelayClient.Middleware.Worker

  setup do
    opts = [mfa: {Keyword, :fetch, [[value: 1]]}]

    {:ok, pid} = start_supervised({Worker, opts})
    {:ok, pid: pid}
  end

  test "can return the different counts", %{pid: pid} do
    assert {:ok, %{total_count: 0, error_count: 0, success_count: 0}} = Worker.count(pid)
  end

  test "increments total & success counts when result is ok", %{pid: pid} do
    :ok = Worker.exec_async(pid, :value)
    # TODO
    Process.sleep(20)

    assert {:ok, %{total_count: 1, success_count: 1}} = Worker.count(pid)
  end

  test "{:error, reason} increments the error_count", %{pid: pid} do
    :ok = Worker.exec_async(pid, :unknown_value)
    # TODO
    Process.sleep(20)

    assert {:ok, %{total_count: 1, error_count: 1}} = Worker.count(pid)
  end

  @tag :capture_log
  test "any crash increments the error_count" do
    {:ok, pid} = Worker.start_link(mfa: {Kernel, :raise, []})
    :ok = Worker.exec_async(pid, "err")

    Process.sleep(20)

    assert {:ok, %{total_count: 1, error_count: 1}} = Worker.count(pid)
  end

  test "should remove the task from pending once it's done", %{pid: pid} do
    {:ok, ref} = Worker.exec(pid, :value)

     refute Worker.pending?(pid, ref)
  end
end
