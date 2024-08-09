defmodule MishkaChelekomWeb.Router do
  use MishkaChelekomWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {MishkaChelekomWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", MishkaChelekomWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/admin", AdminLive
    live "/admin-form", AdminFormLive

    live "/products", ProductLive.Index, :index
    live "/products/new", ProductLive.Index, :new
    live "/products/:id/edit", ProductLive.Index, :edit

    live "/products/:id", ProductLive.Show, :show
    live "/products/:id/show/edit", ProductLive.Show, :edit

    live "/examples/button", Examples.ButtonLive
    live "/examples/typography", Examples.TypographyLive
    live "/examples/divider", Examples.DividerLive
    live "/examples/badge", Examples.BadgeLive
    live "/examples/avatar", Examples.AvatarLive
    live "/examples/breadcrumb", Examples.BreadcrumbLive
    live "/examples/pagination", Examples.PaginationLive
    live "/examples/accordion", Examples.AccordionLive
    live "/examples/indicator", Examples.IndicatorLive
    live "/examples/alert", Examples.AlertLive
  end

  # Other scopes may use custom stacks.
  # scope "/api", MishkaChelekomWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:mishka_chelekom, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: MishkaChelekomWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
