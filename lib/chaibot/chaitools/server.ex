defmodule Chaibot.Chaitools.Server do
  use GenServer

  alias Porcelain.Process, as: Proc
  alias Porcelain.Result

  @repo_path System.user_home <> "/repos/"

  def start_link(user) do
    GenServer.start_link(__MODULE__, [], name: via_tuple(user))
  end

  defp via_tuple(user) do
    {:via, Registry, {:chaitools_bootstrap, user}}
  end

  def build_stack(user, stack) do
    GenServer.cast(via_tuple(user), {:stack, stack})
  end

  def set_remote(user, response) do
    GenServer.cast(via_tuple(user), {:set_remote, response})
  end

  def set_name(user, name) do
    GenServer.cast(via_tuple(user), {:set_name, name})
  end

  def list(user) do
    GenServer.call(via_tuple(user), :list)
  end

  def set_bot_info(user, {pid, channel}) do
    GenServer.cast(via_tuple(user), {:bot_info, {pid, channel}})
  end

  # Callbacks

  def init(_) do
    {:ok, %{}}
  end

  def handle_call(:list, _from, state) do
    %Result{out: output} = Porcelain.shell("ls -lt", dir: @repo_path)
    Process.send_after(self(), :stop, 1000)
    {:reply, output, state}
  end

  def handle_cast({:bot_info, info}, state) do
    {:noreply, Map.put(state, :bot_info, info)}
  end

  def handle_cast({:stack, stack}, state) do
    proc =
      Porcelain.spawn_shell("chaitools bootstrap #{stack} --no-color",
        dir: @repo_path,
        in: :receive,
        out: {:send, self()})

    {:noreply, Map.put(state, :proc, proc)}
  end

  def handle_cast({:set_name, name}, state) do
    Proc.send_input(state.proc, name <> "\n")

    {:noreply, state}
  end

  def handle_cast({:set_remote, ""}, state) do
    Proc.send_input(state.proc, "\n")
    Process.send_after(self(), :stop, 1000)
    {:noreply, state}
  end

  def handle_cast({:set_remote, remote}, state) do
    Proc.send_input(state.proc, "#{remote}\n")
    Process.send_after(self(), :stop, 5000)
    {:noreply, state}
  end

  def handle_info({_pid, :data, :out, data}, %{bot_info: {bot_pid, channel}} = state) do
    send bot_pid, {:message, data, channel}
    {:noreply, state}
  end

  def handle_info({_pid, :result, result}, state) do
    IO.inspect(result)
    {:noreply, state}
  end

  def handle_info(:stop, state) do
    {:stop, :normal, state}
  end

  def terminate(_normal, _state) do
    :ok
  end
end
