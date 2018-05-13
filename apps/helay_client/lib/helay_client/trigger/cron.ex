defmodule HelayClient.Trigger.Cron do
  use GenServer
  require Logger
  alias HelayClient.Trigger

  def start_link(opts \\ [name: __MODULE__]) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def init(opts) do
    scheduler = Keyword.get(opts, :scheduler, HelayClient.Trigger.Scheduler)

    {:ok,
     %{
       scheduler: scheduler,
       lookup: %{}
     }}
  end

  def add_job(pid, %Trigger{type: :cron} = t) do
    GenServer.call(pid, {:add_job, t})
  end

  def handle_call(
        {:add_job, %Trigger{args: args, name: name} = t},
        _from,
        %{scheduler: scheduler, lookup: lookup} = state
      ) do
    input = Map.get(args, "input")

    schedule =
      args
      |> Map.get("schedule")
      |> Crontab.CronExpression.Parser.parse!()

    job =
      scheduler.new_job()
      |> Quantum.Job.set_schedule(schedule)
      |> Quantum.Job.set_task(make_task(self(), t, input))

    Logger.info("Added task #{inspect(job)}")

    {:reply, {scheduler.add_job(job), job}, %{state | lookup: Map.put(lookup, name, job)}}
  end

  def handle_info({:completed, result}, state) do
    Logger.info("Task completed with #{inspect(result)}")
    {:noreply, state}
  end

  defp make_task(pid, trigger, input) do
    fn ->
      send(pid, {:completed, Trigger.yield(trigger, input)})
    end
  end
end
