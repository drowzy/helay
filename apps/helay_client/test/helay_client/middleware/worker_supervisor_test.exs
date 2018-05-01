defmodule HelayClient.Middleware.WorkerSupervisorTest do
  use ExUnit.Case

  alias HelayClient.Middleware.WorkerSupervisor

  setup do
    {:ok, pid} = start_supervised({WorkerSupervisor, []})
    {:ok, id} = WorkerSupervisor.start_proc(pid, "test_proc", [])
    {:ok, id: id, pid: pid}
  end

  test "start_proc/2 with an already existing id returns an error", %{id: id, pid: pid} do
    assert {:error, {:already_started, _pid}} = WorkerSupervisor.start_proc(pid, id, [])
  end

  test "exists?/1 returns true if there's a proc with id", %{id: id} do
    assert WorkerSupervisor.exists?(id)
  end

  test "find/1 returns the pid of proc if it exists", %{id: id} do
    assert {:ok, _pid} = WorkerSupervisor.find(id)
  end

  test "find/1 returns {:error, :not_found} when a proc does not exits" do
    assert {:error, :not_found} = WorkerSupervisor.find("does_not_exist")
  end
end
