defmodule Chaibot.Bitbucket.API do
  use Tesla

  plug Tesla.Middleware.JSON
  adapter Tesla.Adapter.Hackney
  adapter :hackney, [ssl_options: [{:versions, [:'tlsv1.2']}]]

  def client(username, password, opts \\ %{}) do
    Tesla.build_client [
      {Tesla.Middleware.BasicAuth, Map.merge(%{username: username, password: password}, opts)}
    ]
  end

  def readme(client, user: user, repo: repo) do
    get(client, readme_url(user, repo)).body["data"]
  end

  def readme_url(user, repo) do
    "https://api.bitbucket.org/1.0/repositories/#{user}/#{repo}/src/master/README.md" 
  end
end
