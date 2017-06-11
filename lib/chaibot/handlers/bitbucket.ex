defmodule Chaibot.Handler.Bitbucket do
  use Chaibot

  @bitbucket_user Application.get_env(:chaibot, __MODULE__)[:username]
  @bitbucket_password Application.get_env(:chaibot, __MODULE__)[:password]

  def match?(text) do
    Regex.match?(~r/^bitbucket/, text)
  end

  def run(text, args) when is_binary(text) do
    [_ | cmds] =
      text
      |> String.split(" ")
    run(cmds, args)
  end

  def run(["readme", user, repo], message: message, slack: slack) do
    client = Chaibot.Bitbucket.API.client(@bitbucket_user, @bitbucket_password)

    client
    |> Chaibot.Bitbucket.API.readme(user: user, repo: repo)
    |> send_message(slack, message)
  end
end
