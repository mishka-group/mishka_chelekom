# autocomplete (mob)

A text field that suggests completions as you type. See [README](README.md) for the rules every Mob
component shares.

## Generate
`mix mishka.ui.gen.mob autocomplete` → `lib/<app>/components/autocomplete.ex`, tag
`<Autocomplete />`. With `--module-prefix mishka_` it is `<MishkaAutocomplete />`.

## Autocomplete or combobox?

They are close enough that the port makes them the same machinery, and keeps the difference the web
component actually draws:

- a **[combobox](combobox.md)** picks from a fixed list — the value is one of the options, and the
  field is a filter over them.
- an **autocomplete** accepts free text and merely *suggests* — **the query is the value**, and
  choosing a suggestion fills it in.

So this renders through the combobox (same filtering, same list surface) but `on_select` hands back
the suggestion's **text**, not an id, which is what a free-text field needs. Every combobox prop is
forwarded; this drops only `:suggestions`.

## Example

```elixir
~MOB"""
<Column fill_width={true} on_tap={{self(), :close}}>
  <MishkaAutocomplete
    query={@query}
    suggestions={@cities}
    open={@open?}
    clear={true}
    trigger={true}
    placeholder="Type a city…"
    on_query={:query}
    on_select={:choose}
    on_press={:press}
    on_toggle={:toggle}
    id="city"
  />
</Column>
"""

# Typing is the value, and opens the panel.
def handle_info({:change, :query, text}, socket) do
  {:noreply, socket |> Mob.Socket.assign(:query, text) |> Mob.Socket.assign(:open?, true)}
end

# The chosen suggestion IS the text. Fill the field and close — there is
# nothing left to suggest.
def handle_info({:tap, {:choose, text}}, socket) do
  {:noreply, socket |> Mob.Socket.assign(:query, text) |> Mob.Socket.assign(:open?, false)}
end

# on_press, NOT on_focus — see "A note on focus" below.
def handle_info({:tap, :press}, socket), do: {:noreply, Mob.Socket.assign(socket, :open?, true)}
def handle_info({:tap, :close}, socket), do: {:noreply, Mob.Socket.assign(socket, :open?, false)}
```

## Props

| Prop | Values | Default |
|---|---|---|
| `query` | string | `""` — **this is the value** |
| `suggestions` | list of strings | `[]` |
| `open` | boolean | `false` |
| `filter` | `:starts_with` / `:contains` | `:starts_with` |
| `placeholder` | string | `"Type to search…"` |
| `clear` | boolean | `false` |
| `trigger` | boolean | `false` — a ▾ that opens and closes |
| `empty_text` | string | `"No suggestions"` |
| `disabled` | boolean | `false` |
| `on_query` / `on_select` / `on_clear` | event tags | — |
| `on_press` | event tag | — fires on EVERY tap of the field |
| `on_focus` / `on_blur` / `on_toggle` | event tags | — |
| `trigger_icon` / `clear_icon` | string, or `{closed, open}` | `▾`/`▴` and `✕` |
| `id` | string | `nil` — test tags for the field, buttons and suggestions |

Everything else the [combobox](combobox.md) takes is forwarded too.

Helpers: `suggest/3`, `exact?/2`, `exact_match?/2`.

Not ported: `name` / `required` / `readonly` (form plumbing), `auto_highlight` (there is no focus
ring to highlight), `inline` (typing the completion into the field ahead of the caret fights every
mobile IME) and the `*_class` attrs.

## Five things to know

**Prefix, not contains, by default.** `:starts_with` is what "autocomplete" means — you are
completing what someone has begun typing. The combobox defaults the other way, because there you are
searching a list rather than finishing a word. `:contains` is one prop away when you want it.

**Only the exactly-typed suggestion is dropped.** Once the query names a suggestion exactly there is
nothing left to suggest *about that one* — but "Iran" still offers "Iranian Rial", because a longer
completion is precisely what a prefix-typer is after. Blanking the whole list on an exact match hid
those completions and then claimed there was nothing to suggest.

**An empty panel must be true.** If dropping the exact match leaves nothing at all, no panel is
drawn — rather than one saying "No suggestions", which is false when the reason is that you already
typed the answer. A query that genuinely matches nothing still says so; that is the distinction.

**Opening and closing is the screen's, and needs a backdrop.** Tapping the field reports `on_press`,
the first keystroke reports `on_query`, an optional ▾ reports `on_toggle`. Closing on a tap
**outside** needs an `on_tap` on the container around the control — the panel renders in flow, so
nothing covers the page to catch it. That is the list's length, not a missing primitive: `popover`
floats its panel over the page now, and its window would not have caught the outside tap either. Do
not close on `on_blur`: choosing a suggestion blurs the field too, so you would close before the
choice registered.

**Close when you fill.** Choosing a suggestion should set the query *and* clear `open?`. The
component cannot do it for you — `open` is your assign — and a panel left hanging over the answer is
the thing users notice first.

## A note on focus

`on_focus` fires on a focus *change*, and that is why **`on_press` exists and is what you should
open on**. A field that already has the caret reports no new focus, and closing the panel does not
take the caret away — so "tap the field to open it" did nothing the second time, while the caret
blinked away as if the field were live. Only the ▾ worked, or tapping somewhere that happened to
steal focus first, which nobody would guess.

`on_press` fires on every tap. It observes the pointer without consuming it, so the field still
places its caret and raises the keyboard exactly as before. Keep `on_focus` for things that
genuinely care about focus.

## Related
`combobox` (pick from a fixed list), `pills_input` (the free-text control on the same page),
`tags_input`, `select`.
