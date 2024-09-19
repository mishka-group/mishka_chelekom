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
    live "/examples/blockquote", Examples.BlockquoteLive
    live "/examples/list", Examples.ListLive
    live "/examples/skeleton", Examples.SkeletonLive
    live "/examples/spinner", Examples.SpinnerLive
    live "/examples/card", Examples.CardLive
    live "/examples/overlay", Examples.OverlayLive
    live "/examples/modal", Examples.ModalLive
    live "/examples/banner", Examples.BannerLive
    live "/examples/keyboard", Examples.KeyboardLive
    live "/examples/progress", Examples.ProgressLive
    live "/examples/chat", Examples.ChatLive
    live "/examples/drawer", Examples.DrawerLive
    live "/examples/footer", Examples.FooterLive
    live "/examples/gallery", Examples.GalleryLive
    live "/examples/popover", Examples.PopoverLive
    live "/examples/tooltip", Examples.TooltipLive
    live "/examples/navbar", Examples.NavbarLive
    live "/examples/rating", Examples.RatingLive
    live "/examples/video", Examples.VideoLive
    live "/examples/toast", Examples.ToastLive
    live "/examples/timeline", Examples.TimelineLive
    live "/examples/toast-group", Examples.ToastGroupLive
    live "/examples/dropdown", Examples.DropdownLive
    live "/examples/jumbotron", Examples.JumbotronLive
    live "/examples/tabs", Examples.TabsLive
    live "/examples/stepper", Examples.StepperLive
    live "/examples/crypto", Examples.CryptoLive
    live "/examples/image", Examples.ImageLive
    live "/examples/menu", Examples.MenuLive
    live "/examples/sidebar", Examples.SidebarLive
    live "/examples/table-content", Examples.TableContentLive
    live "/examples/carousel", Examples.CarouselLive
    live "/examples/speed-dial", Examples.SpeedDialLive
    live "/examples/mega-menu", Examples.MegaMenuLive
    live "/examples/devices", Examples.DeviceMockupLive
    live "/examples/text-field", Examples.TextFieldLive
    live "/examples/password-field", Examples.PasswordFieldLive
    live "/examples/email-field", Examples.EmailFieldLive
    live "/examples/number-field", Examples.NumberFieldLive
    live "/examples/color-field", Examples.ColorFieldLive
    live "/examples/tel-field", Examples.TelFieldLive
    live "/examples/url-field", Examples.UrlFieldLive
    live "/examples/checkbox-field", Examples.CheckboxFieldLive
    live "/examples/toggle-field", Examples.ToggleFieldLive
    live "/examples/radio-field", Examples.RadioFieldLive
    live "/examples/datetime-field", Examples.DateTimeFieldLive
    live "/examples/range-field", Examples.RangeFieldLive
    live "/examples/file-field", Examples.FileFieldLive
    live "/examples/textarea-field", Examples.TextareaFieldLive
    live "/examples/select-field", Examples.NativeSelectLive
    live "/examples/search-field", Examples.SearchFieldLive
    live "/examples/input-field", Examples.InputFieldLive
    live "/examples/fieldset-field", Examples.FieldsetFieldLive
    live "/examples/form", Examples.FormWrapperLive
    live "/examples/table", Examples.TableLive

    live "/examples/user-form", Examples.UserFormLive
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
