defmodule MishkaMob.Components.MishkaJsonInput do
  @moduledoc """
  Native Mob port of Mishka Chelekom's **headless JSON Input** — a multi-line
  field for JSON with a validated error state.

  The web component is explicit that parsing is the *server's* job and there is
  no JS involved, which makes it one of the most faithful ports here: the same
  division of labour, with `Jason` on the same side of the wire.

  ## Multi-line — Android only

  Mob's `TextField` was single-line only; this component needed a textarea, so
  the bridge grew a `lines` prop (`singleLine = false` plus `minLines`/`maxLines`
  when `lines > 1`). The return key then inserts a newline rather than
  submitting, which is the correct behaviour for a textarea and means
  `on_submit` is only meaningful on a single-line field.

  That growth happened in **our** bridge. iOS's `MobTextField` renders a
  single-line field whatever `lines` says, and styles itself with
  `.textFieldStyle(.roundedBorder)` rather than reading `background`,
  `border_color` or `border_width` at all — so on iOS this is a one-line box
  with the system's own chrome, and the invalid state shows only in the message
  underneath. See `IOS_TODO.md`.

  ## Props

  | Prop | Values | Default | Meaning |
  |------|--------|---------|---------|
  | `value` | string | `""` | The raw text. Never reformatted as you type. |
  | `lines` | integer | `6` | Height of the field, in rows. |
  | `placeholder` | string | `"{ }"` | Empty-state hint. |
  | `invalid` | boolean | derived | Force the error state; otherwise `validate/1` decides. |
  | `error_text` | string | the parser's message | What to show under the field. |
  | `show_error` | boolean | `true` | Render the message at all. |
  | `disabled` | boolean | `false` | Mutes and unwires. |
  | `on_change` | event tag (atom) | — | `{:change, tag, text}` per keystroke. |
  | `error_color` | color token / ARGB int | `:error` | The invalid border and message. |
  | `background` / `border_color` / `border_width` / `padding` | | | The field. |
  | `id` | string | `nil` | Test tag on the field; the message gets `<id>-error`. |

  Not ported: `name` / `form` (form plumbing). `id` IS ported, as a test handle.

  ## Asking about the error requires an `id`

  A page shows several of these at once — a valid one, a broken one — and they
  all render into the same screen. "Is an error showing?" is therefore not a
  question you can ask the page; it is a question about one field. Give the
  field an `id` and its message is addressable as `error_id(id)`.
  """

  import Mob.Sigil

  alias MishkaMob.Components.Event

  @doc "Composite expander (`<MishkaJsonInput />`). Delegates to `json_input/1`."
  @spec expand(map(), [map()], map()) :: map()
  def expand(props, _children, _ctx), do: json_input(props)

  @doc """
  The JSON field.

      json_input(value: @draft, on_change: :draft)
  """
  @spec json_input(map() | keyword()) :: map()
  def json_input(props \\ %{}) do
    props = Map.new(props)
    disabled? = truthy?(Map.get(props, :disabled, false))
    text = Map.get(props, :value, "")
    result = validate(text)
    invalid? = invalid?(props, result)

    field =
      ~MOB"""
      <TextField
        value={text}
        placeholder={Map.get(props, :placeholder, "{ }")}
        lines={Map.get(props, :lines, 6)}
        fill_width={true}
        background={Map.get(props, :background, :surface)}
        padding={Map.get(props, :padding, :space_sm)}
        border_color={if(invalid?, do: danger(props), else: Map.get(props, :border_color, :border))}
        border_width={Map.get(props, :border_width, 1)}
        enabled={not disabled?}
      />
      """
      |> tag(Map.get(props, :id))
      |> put(:on_change, if(disabled?, do: nil, else: Event.handler(Map.get(props, :on_change))))

    ~MOB"""
    <Column fill_width={true}>
      {field}
      {message(props, result, invalid?, Map.get(props, :id))}
    </Column>
    """
  end

  @doc """
  The test tag on the error message, given the field's `id`.

  A page usually shows several of these side by side — a valid one and a broken
  one — so "is the error message on screen?" is not a question about the page,
  it is a question about *one field*. This is the handle for asking it.

      iex> MishkaMob.Components.MishkaJsonInput.error_id("config")
      "config-error"
  """
  @spec error_id(String.t()) :: String.t()
  def error_id(id) when is_binary(id), do: id <> "-error"

  @doc """
  Validate the text.

  Blank is `:empty` rather than an error — an untouched field is not a mistake,
  and the web component does not paint one red either.

      iex> MishkaMob.Components.MishkaJsonInput.validate(~s({"a": 1}))
      {:ok, %{"a" => 1}}

      iex> MishkaMob.Components.MishkaJsonInput.validate("   ")
      :empty

      iex> match?({:error, _}, MishkaMob.Components.MishkaJsonInput.validate("{oops}"))
      true

  A bare scalar is valid JSON, and treating it as an error would be wrong:

      iex> MishkaMob.Components.MishkaJsonInput.validate("42")
      {:ok, 42}
  """
  @spec validate(String.t() | nil) :: {:ok, term()} | {:error, String.t()} | :empty
  def validate(text) when is_binary(text) do
    if String.trim(text) == "" do
      :empty
    else
      case Jason.decode(text) do
        {:ok, decoded} -> {:ok, decoded}
        {:error, error} -> {:error, describe(error)}
      end
    end
  end

  def validate(_), do: :empty

  @doc """
  Pretty-print the text, or return it untouched when it will not parse.

  Formatting is a deliberate action — a button, a blur — never a keystroke:
  reformatting as someone types would move the cursor out from under them.

      iex> MishkaMob.Components.MishkaJsonInput.format(~s({"a":1}))
      "{\\n  \\"a\\": 1\\n}"

      iex> MishkaMob.Components.MishkaJsonInput.format("{oops}")
      "{oops}"
  """
  @spec format(String.t() | nil) :: String.t()
  def format(text) do
    case validate(text) do
      {:ok, decoded} -> Jason.encode!(decoded, pretty: true)
      _ -> text || ""
    end
  end

  @doc """
  Whether the field should show its error state — explicit `invalid` wins,
  otherwise the parse decides.

      iex> MishkaMob.Components.MishkaJsonInput.invalid?(%{}, {:error, "nope"})
      true

      iex> MishkaMob.Components.MishkaJsonInput.invalid?(%{}, :empty)
      false

      iex> MishkaMob.Components.MishkaJsonInput.invalid?(%{invalid: true}, {:ok, 1})
      true
  """
  @spec invalid?(map() | keyword(), {:ok, term()} | {:error, String.t()} | :empty) :: boolean()
  def invalid?(props, result) do
    case Map.get(Map.new(props), :invalid) do
      nil -> match?({:error, _}, result)
      forced -> truthy?(forced)
    end
  end

  # The message carries its own tag (`<id>-error`) rather than borrowing the
  # field's. A showcase page — and any real form — shows several of these at
  # once, so a test that asks the PAGE whether an error is visible cannot tell
  # which field it belongs to: a permanently-broken example next door answers
  # for everyone. That is not hypothetical; it is what made three tests here
  # either fail for the wrong reason or pass while asserting nothing.
  defp message(props, result, invalid?, id) do
    with true <- truthy?(Map.get(props, :show_error, true)),
         true <- invalid?,
         text when is_binary(text) <- error_text(props, result) do
      ~MOB"""
      <Column fill_width={true}>
        <Spacer size={6} />
        <Text text={text} text_size={:sm} text_color={danger(props)} />
      </Column>
      """
      |> tag_message(id)
    else
      _ -> nil
    end
  end

  defp tag_message(node, id) when is_binary(id) do
    [spacer, text] = node.children
    %{node | children: [spacer, tag(text, error_id(id))]}
  end

  defp tag_message(node, _id), do: node

  # `invalid: true` on text that PARSES means the caller knows something the
  # parser does not — a schema rejected it, the server said no. Claiming
  # "Invalid JSON" there is a lie about the one thing this component can check,
  # so without an `error_text` to show it says nothing and merely tints.
  defp error_text(props, result) do
    case Map.get(props, :error_text) do
      text when is_binary(text) -> text
      _ -> from_result(result)
    end
  end

  defp from_result({:error, reason}), do: reason
  defp from_result(_), do: nil

  # Jason's exceptions carry position information; the message alone is more
  # use in a 30-point-tall error line than the struct's inspect output.
  defp describe(%Jason.DecodeError{} = error), do: Exception.message(error)
  defp describe(other), do: inspect(other)

  # `:error` is a THEME token; `:danger` was not one anywhere — not in
  # deps/mob/lib/mob/theme/*.ex and not in the renderer's @colors fallback. An
  # unresolved token serialises as the bare string "danger", and the two places
  # this component used it are the two places the error state is expressed:
  #
  #   * as a border_color it made longColorProp return nil, and nodeModifier
  #     only draws a border when it has BOTH a colour and a width — so invalid
  #     JSON did not turn the box red, it deleted the box's outline;
  #   * as a text_color it left the parser's message in the ordinary body
  #     colour on Android, and fully transparent (alpha 0) on iOS, where the
  #     only feedback about broken JSON was therefore invisible.
  defp danger(props), do: Map.get(props, :error_color, :error)

  defp tag(node, nil), do: node
  defp tag(node, id), do: %{node | props: Map.put(node.props, :id, id)}

  defp put(node, _key, nil), do: node
  defp put(node, key, value), do: %{node | props: Map.put(node.props, key, value)}

  defp truthy?(nil), do: false
  defp truthy?(false), do: false
  defp truthy?(_), do: true
end
