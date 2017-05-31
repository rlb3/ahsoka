defmodule Chaibot.Web.Router do
  use Chaibot.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", Chaibot.Web do
    pipe_through :api
  end
end
