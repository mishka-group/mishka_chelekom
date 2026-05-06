defmodule MishkaChelekom.Test.Runtime.GettextStub do
  @moduledoc """
  Bare-bones `gettext/1`, `gettext/2`, `dgettext/2,3`, `ngettext/3,4`
  passthroughs for the test-vendored runtime compiler.

  The real runtime CMS uses `MishkaCmsCore.Gettext` which routes through
  `Gettext.Backend`. Chelekom's test env doesn't carry a Gettext backend
  and we don't translate anything in tests anyway — so each macro just
  expands to the input msgid (or the singular/plural string for ngettext).

  Imported by the vendored `MishkaChelekom.Test.Runtime.Compilers.ComponentCompiler`
  into every compiled component module so chelekom-side bundle rendering
  works without host-app dependencies.
  """

  defmacro gettext(msgid), do: quote(do: unquote(msgid))
  defmacro gettext(msgid, _bindings), do: quote(do: unquote(msgid))
  defmacro dgettext(_domain, msgid), do: quote(do: unquote(msgid))
  defmacro dgettext(_domain, msgid, _bindings), do: quote(do: unquote(msgid))

  defmacro ngettext(singular, plural, count) do
    quote do
      if unquote(count) == 1, do: unquote(singular), else: unquote(plural)
    end
  end

  defmacro ngettext(singular, plural, count, _bindings) do
    quote do
      if unquote(count) == 1, do: unquote(singular), else: unquote(plural)
    end
  end

  defmacro dngettext(_domain, singular, plural, count) do
    quote do
      if unquote(count) == 1, do: unquote(singular), else: unquote(plural)
    end
  end

  # Form field errors call `translate_error/1` to localize messages.
  # The host app normally provides this in `MyAppWeb.CoreComponents`;
  # the test stub passes the error tuple through verbatim.
  # Defined as a function (not macro) so it works inside helper-defp
  # bodies that call it dynamically.
  def translate_error({msg, _opts}), do: msg
  def translate_error(msg) when is_binary(msg), do: msg
  def translate_error(_), do: ""
end
