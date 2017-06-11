# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :chaibot,
  ecto_repos: [Chaibot.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :chaibot, Chaibot.Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "bWBzRfso7SdkpZdUP96wHYyw+emJPlBWEClLySi58wjqUBk9plzIsCPPZ86KplDn",
  render_errors: [view: Chaibot.Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: Chaibot.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :slack, api_token: System.get_env("SLACK_TOKEN")
config :porcelain, :driver, Porcelain.Driver.Goon

config :chaibot, Chaibot.Ahsoka,
  [{Chaibot.Handler.Chaitools, []},
   {Chaibot.Handler.Bitbucket, []}]

config :chaibot, Chaibot.Handler.Bitbucket,
  [username: System.get_env("BITBUCKET_USER"), password: System.get_env("BITBUCKET_PASS")]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
