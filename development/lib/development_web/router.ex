defmodule DevelopmentWeb.Router do
  use DevelopmentWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {DevelopmentWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DevelopmentWeb do
    pipe_through :browser

    get "/", PageController, :home

    live "/showcase", Showcase.IndexLive, :index
    live "/showcase/headless", Showcase.HeadlessLive, :index
    live "/showcase/headless/:component", Showcase.HeadlessLive, :show
    live "/showcase/:component", Showcase.ComponentLive, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", DevelopmentWeb do
  #   pipe_through :api
  # end
end
