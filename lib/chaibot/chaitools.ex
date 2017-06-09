defmodule Chaibot.Chaitools do
  @behaviour Chaibot.Behaviour

  def match?(text) do
    text
    |> String.match?(~r/^bootstrap/)
  end

  def run(text, args) when is_binary(text) do
    [_ | cmds] = text |> String.split(" ")
    run(cmds, args)
  end

  def run(["list"], message: message,  slack: slack) do
      message.user
      |> start_session

      text = message.user
      |> Chaibot.Chaitools.Server.list()

      send_message(text, slack, message)
  end

  def run(["name", name], message: message, slack: slack) do
      if session?(message.user) do
        name
        |> String.trim
        |> name_repo(message)
      else
        send_message("Bootstrap stack not selected.", slack, message)
      end
  end

  def run(["remote", remote], message: message, slack: slack) do
      if session?(message.user) do
        remote
        |> String.trim
        |> repo_remote(message)
      else
        send_message("Bootstrap stack not selected.", slack, message)
      end
  end

  def run([stack], message: message, slack: slack) when stack in ["elixir", "rails", "ios", "ember", "android", "react-native"]do
      message.user
      |> start_session

      message.user
      |> Chaibot.Chaitools.Server.set_bot_info({slack, message.channel})

      message.user
      |> Chaibot.Chaitools.Server.build_stack(stack)
  end

  defp start_session(username) do
    Chaibot.Chaitools.Supervisor.build_tool(for: username)
  end

  defp session?(username) do
      case Registry.lookup(:chaitools_bootstrap, username) do
        [{_pid, _}] -> true
      [] -> false
    end
  end

  defp name_repo(name, message) do
    message.user
    |> Chaibot.Chaitools.Server.set_name(name)
  end

  defp repo_remote("none", message) do
    message.user
    |> Chaibot.Chaitools.Server.set_remote("")
  end

  defp repo_remote(remote, message) do
    message.user
    |> Chaibot.Chaitools.Server.set_remote(remote)
  end

  def send_message(text, slack, message) do
    send slack, {:message, text, message.channel}
  end
end
