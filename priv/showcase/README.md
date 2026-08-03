# `priv/showcase/` — hand-authored examples for a CMS page builder

This directory is the reference implementation of a contract. If you are building
a component library for MishkaCMS — Chelekom or anyone else's — this is the shape
your kit emits so that a page builder can present your components well.

Nothing here is required. A kit that ships no showcase still installs, still
renders, and still appears in the palette. What it loses is the difference
between a component that lands as an empty rectangle and one that lands looking
like itself.

---

## Why this exists at all

A page builder asks a component library three different questions, and they have
three different answers:

| The reader does this | The builder asks | Answered by |
| --- | --- | --- |
| Drags the component onto the page | "What should this look like immediately?" | **`furnishing`** |
| Opens the examples modal (`!`) | "Show me a finished one I can edit" | **`examples`** |
| Opens the wizard tab | "Give me *this* one — outline, large, amber" | the component's own `helpers[].discriminators` |

The third is generated. `MishkaChelekom.CmsBundle.Examples` harvests every
invocation from the docs pages and selects for **option coverage** — one example
per distinct option value — which is exactly right for a consumer asking "which
invocation demonstrates `variant="outline"`".

It is the wrong answer to the first two. Option coverage produces a hundred rows
reading *"Banner Default variant natural"*, *"Banner Default variant White"* —
and the builder's wizard already answers that question better, with a live
preview. So the harvest is left alone, and anything authored here is laid over
the top by `MishkaChelekom.CmsBundle.Showcase`.

A component with no file in this directory is untouched and ships the harvest
exactly as before.

---

## One file per component

Named for the component, including the kit prefix:

```
priv/showcase/chelekom-card.json
priv/showcase/chelekom-jumbotron.json
```

```jsonc
{
  "name": "chelekom-card",

  // What lands on a plain drag-and-drop, when the reader has opened neither
  // the examples modal nor the wizard.
  "furnishing": {
    "body": "<.component component_name=\"chelekom-card-title\" site=\"Global\">Your heading</.component>",
    "slots": []
  },

  // Three to five finished blocks. The first is the base.
  "examples": [
    {
      "label": "Pricing card with feature list",
      "source": "<.component component_name=\"chelekom-card\" site=\"Global\" …>…</.component>",
      "non_default_options": { "variant": "outline" }
    }
  ]
}
```

Both top-level content keys are optional. `furnishing` alone is valid, `examples`
alone is valid. `name` is required — it is what the entry attaches to.

Validate a file against [`_schema.json`](_schema.json) before committing it.

---

## `furnishing` — the drop default

The single most-used path in a page builder is drag, drop, look. A component that
arrives with nothing inside it is a blank strip the author has to open the
inspector to identify.

| Key | Meaning |
| --- | --- |
| `body` | HEEx written *between* the component's tags |
| `slots` | Sample `<:name>` entries, for a component whose content is a list |

```json
"furnishing": {
  "body": "",
  "slots": [
    { "name": "item", "attrs": { "title": "First section" }, "body": "What this section covers." },
    { "name": "item", "attrs": { "title": "Second section" }, "body": "And what this one covers." }
  ]
}
```

Rules that matter:

- **Default options only.** No `variant`, `color`, `size`. A minimal install ships
  only the defaults, and a drop must never render as an error.
- **Repeat a slot name** to place several entries — two `<:item>` blocks are two
  entries, not one.
- **`attrs` are the slot's own attributes**, written verbatim. An `<:option>`
  without a `value` is a choice that cannot be chosen.
- **`"body": ""` with `"slots": []` means genuinely empty**, and is honoured. A
  spinner has nothing to say. This is the one answer the consumer's own inference
  cannot express, which is the main reason to declare a furnishing at all.
- **Never write `<:inner_block>`.** The HEEx compiler rejects the name outright;
  content between the tags is `body`.

The consumer validates this shape with `MishkaCmsCore.Builder.Furnishing`. A
malformed furnishing is dropped and the consumer falls back to inference — it
never raises into a palette render.

---

## `examples` — finished blocks

Three to five. Not twelve, and not one per variant.

| Key | Required | Meaning |
| --- | --- | --- |
| `label` | yes | What the block **is** |
| `source` | yes | Complete, self-contained HEEx |

### Labels name the thing, not the option

```
✅  "Pricing card with feature list"
✅  "Cookie consent bar with accept and decline"
✅  "SaaS hero with dual call-to-action"

❌  "Outline variant"
❌  "Base"
❌  "Card 3"
```

The reader is scanning for a block to use. `"Outline variant"` tells them nothing
they cannot see, and the wizard covers it anyway.

### `requires` is derived — you do not declare it

MishkaCMS installs a kit **minimal by default** — only the default variant — and
physically drops the helper clauses the selection rules out. An example pinned to
`variant="outline"` is dead markup on such an install, so the bundle carries a
`requires` map letting the consumer hide it rather than render it broken.

That map is read **off your markup**, not off anything you write beside it. The
root invocation's attributes are intersected with the component's own
`helpers[].discriminators`, so:

```
<.component component_name="chelekom-card" site="Global" variant="outline" class="max-w-sm">
```

becomes `"requires": {"variant": ["outline"]}` — the same shape the harvest emits.
A value that is not one of the component's options (`class="max-w-sm"`) is a
Tailwind passthrough and is ignored.

This is deliberate. Asked to *list* the non-default options they used, an author
writes prose — *"large — hero-scale numerals so the band reads at arm's length"* —
and that lands in `requires` as an axis no install can satisfy, hiding the example
on every install including a full one. The markup cannot be wrong about itself.

Prefer default options anyway. Reach for a non-default one when it genuinely makes
the block better; nothing else is needed from you.

---

## Rules for `source`

These are not style preferences. Each one is a way the block fails to render.

1. **Runtime form, always.** Every invocation, including nested children, is
   `<.component component_name="chelekom-x" site="Global" …>`. Never the kit's own
   `<.card>` form — the CMS compiles components by name, not by import.
2. **Only declared attributes and slots.** An invented attribute is silently
   dropped and the block renders wrong.
3. **Only option values in `helpers[].discriminators`.** A value with no clause
   falls to the catch-all and renders as the default, so the example claims
   something it does not show.
4. **Supply required attributes.** An attribute declared `required` with no
   default is an assign the template reads and nothing provides — reading it
   raises `KeyError` and takes the canvas down. `id` especially: components build
   their own handlers as `hide("##{@id}")`, and `id=""` makes that selector `"#"`,
   which matches nothing.
5. **Ids unique within the file**, or two examples fight over the same element.
6. **Self-contained.** No assigns the CMS will not have, no `:let`, no `phx-`
   handlers needing a LiveView of their own, no comprehensions over data that does
   not exist, no invented image URLs.
7. **Plain Tailwind utilities only.** No daisyUI, no `<style>` blocks, no `style=`
   attributes — the CMS compiles Tailwind from the server-rendered markup, and a
   class it never sees gets no rule.
8. **Real copy.** Never lorem ipsum, never the literal words "Example" or "Base".
   The reader is deciding whether to use the block; placeholder text makes that
   decision impossible.

---

## How it reaches the bundle

`mix mishka.ui.export` applies the overlay after harvesting:

```elixir
components
|> populate_examples(demos_dir, kit_component_set, bundle_name)
|> MishkaChelekom.CmsBundle.Showcase.overlay(showcase_dir)
```

Per component with a file here:

| Bundle field | After overlay |
| --- | --- |
| `examples` | the authored sources |
| `extra.examples` | the authored entries, `base: true` on the first, `requires` from `non_default_options` |
| `extra.furnishing` | the drop default, verbatim |
| `extra.demo_examples` | **untouched** — the demo harness still renders every harvested invocation |

A malformed file is skipped and named in the export log. One bad file costs its
own component; the bundle still ships.

---

## Checklist before committing a file

- [ ] Validates against `_schema.json`
- [ ] 3–5 examples, each a block someone would actually ship
- [ ] Labels say what the block *is*
- [ ] Every attribute and slot exists on the component it is written on — including nested children
- [ ] Every option value appears in that component's discriminators
- [ ] Required attributes supplied; ids literal and unique
- [ ] `furnishing` uses default options only
- [ ] No daisyUI, no `style=`, no `:let`, no invented URLs
- [ ] Non-default options declared in `non_default_options`
