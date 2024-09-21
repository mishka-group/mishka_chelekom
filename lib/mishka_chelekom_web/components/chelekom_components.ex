defmodule MishkaChelekomComponents do
  use Phoenix.Component

  defmacro __using__(_) do
    quote do
      import MishkaChelekom.{
        Accordion,
        Alert,
        Avatar,
        Badge,
        Banner,
        Blockquote,
        Breadcrumb,
        Button,
        Card,
        Carousel,
        Chat,
        DateTimeField,
        DeviceMockup,
        Drawer,
        Dropdown,
        FileField,
        Footer,
        Form,
        Gallery,
        Hr,
        Image,
        Indicator,
        TextField,
        PasswordField,
        EmailField,
        NumberField,
        ColorField,
        TelField,
        UrlField,
        CheckboxField,
        ToggleField,
        Jumbotron,
        Keyboard,
        List,
        MegaMenu,
        Menu,
        Modal,
        Navbar,
        Pagination,
        Popover,
        Progress,
        RadioField,
        RangeField,
        Rating,
        SearchField,
        NativeSelect,
        FieldsetField,
        FormWrapper,
        Sidebar,
        Skeleton,
        SpeedDial,
        Spinner,
        Stepper,
        Table,
        Tabs,
        TextareaField,
        Timeline,
        TimepickerInput,
        Toast,
        Tooltip,
        ToggleInput,
        TableContent,
        Video
      }
    end
  end

  @doc """
  Translates an error message using gettext.
  """
  def translate_error({msg, opts}) do
    # When using gettext, we typically pass the strings we want
    # to translate as a static argument:
    #
    #     # Translate the number of files with plural rules
    #     dngettext("errors", "1 file", "%{count} files", count)
    #
    # However the error messages in our forms and APIs are generated
    # dynamically, so we need to translate them by calling Gettext
    # with our gettext backend as first argument. Translations are
    # available in the errors.po file (as we use the "errors" domain).
    if count = opts[:count] do
      Gettext.dngettext(MishkaChelekomWeb.Gettext, "errors", msg, msg, count, opts)
    else
      Gettext.dgettext(MishkaChelekomWeb.Gettext, "errors", msg, opts)
    end
  end

  @doc """
  Translates the errors for a field from a keyword list of errors.
  """
  def translate_errors(errors, field) when is_list(errors) do
    for {^field, {msg, opts}} <- errors, do: translate_error({msg, opts})
  end

  @doc """
  Renders a [Heroicon](https://heroicons.com).

  Heroicons come in three styles – outline, solid, and mini.
  By default, the outline style is used, but solid and mini may
  be applied by using the `-solid` and `-mini` suffix.

  You can customize the size and colors of the icons by setting
  width, height, and background color classes.

  Icons are extracted from the `deps/heroicons` directory and bundled within
  your compiled app.css by the plugin in your `assets/tailwind.config.js`.

  ## Examples

      <.icon name="hero-x-mark-solid" />
      <.icon name="hero-arrow-path" class="ml-1 w-3 h-3 animate-spin" />
  """
  attr :name, :string, required: true, doc: "Specifies the name of the element"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"

  def icon(%{name: "hero-" <> _, class: class} = assigns) when is_list(class) do
    ~H"""
    <span class={[@name] ++ @class} />
    """
  end

  def icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
