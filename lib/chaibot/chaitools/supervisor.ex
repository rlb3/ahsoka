defmodule Chaibot.Chaitools.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def build_tool(for: user) do
    Supervisor.start_child(__MODULE__, [user])
  end

  def init(_) do
    children = [
      worker(Chaibot.Chaitools.Server, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end
end
