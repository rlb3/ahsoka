defmodule Chaibot.Ahsoka do
  use Slack

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(%{type: "message", channel: channel, text: "bootstrap list"} = message, slack, state) do
    message.user
    |> start_session

    message.user
    |> Chaibot.Chaitools.Server.list()
    |> send_message(channel, slack)

    {:ok, state}
  end

  def handle_event(%{type: "message", text: "bootstrap remote " <> remote} = message, slack, state) do
    if session?(message.user) do
      remote
      |> String.trim
      |> repo_remote(message)
    else
      send_message("Bootstrap stack not selected.", message.channel, slack)
    end

    {:ok, state}
  end

  def handle_event(%{type: "message", text: "bootstrap name " <> name} = message, slack, state) do
    if session?(message.user) do
      name
      |> String.trim
      |> name_repo(message)
    else
      send_message("Bootstrap stack not selected.", message.channel, slack)
    end

    {:ok, state}
  end

  def handle_event(%{type: "message", text: "bootstrap " <> stack} = message, _slack, state) do
      stack
      |> String.trim
      |> start_repo(message)

    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, slack, state) do
    send_message(text, channel, slack)

    {:ok, state}
  end

  def handle_info(_, _, state), do: {:ok, state}

  defp start_session(username) do
    Chaibot.Chaitools.Supervisor.build_tool(for: username)
  end

  defp start_repo(nil, _) do
    nil
  end

  defp start_repo(stack, message) do
    message.user
    |> start_session

    message.user
    |> Chaibot.Chaitools.Server.set_bot_info({self(), message.channel})

    message.user
    |> Chaibot.Chaitools.Server.build_stack(stack)
  end

  defp name_repo(name, message) do
    message.user
    |> Chaibot.Chaitools.Server.set_name(name)
  end

  defp session?(username) do
    case Chaibot.Chaitools.Supervisor.build_tool(for: username) do
      {:ok, _pid} ->
        false
      {:error, {:already_started, _pid}} ->
        true
    end
  end

  defp repo_remote("none", message) do
    message.user
    |> Chaibot.Chaitools.Server.set_remote("")
  end

  defp repo_remote(remote, message) do
    message.user
    |> Chaibot.Chaitools.Server.set_remote(remote)
  end
end
