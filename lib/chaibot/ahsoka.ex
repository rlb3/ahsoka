defmodule Chaibot.Ahsoka do
  use Slack

  @handlers Application.get_env(:chaibot, __MODULE__)

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(%{type: "message", text: text} = message, _slack, state) do
    @handlers
    |> Enum.each(fn {handler, _args} ->
      if handler.match?(text) do
        handler.run(text, message: message, slack: self())
      end
    end)

    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, slack, state) do
    send_message(text, channel, slack)

    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}
end
