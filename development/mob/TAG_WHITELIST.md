# Composite tags and the `~MOB` whitelist

Mob 0.7.20. Written up to ask upstream whether there is a supported answer we
missed.

## What we are building

[Mishka Chelekom](https://mishka.tools/chelekom) ships a UI kit of ~72
components as `Mob.Composite`s. A CLI generates them into the developer's own
project, so the modules live in *their* app, not in a Hex package of ours.

A component looks like this:

```elixir
defmodule MyApp.Components.MishkaChip do
  import Mob.Sigil

  def expand(props, children, ctx), do: chip(props, children, ctx)

  def chip(props, _children, _ctx) do
    ~MOB"<Box corner_radius={:radius_full}><Text text={props[:label]} /></Box>"
  end
end
```

registered at boot, the runtime way documented in `Mob.Composite`:

```elixir
Mob.Composite.register(:mishka_chip, {MyApp.Components.MishkaChip, :expand})
```

## How it is called

As a tag, which is the whole point of a composite:

```elixir
~MOB"<MishkaChip label="Elixir" on_toggle={:pick} />"
```

That works — it renders correctly on device.

## The warning

Every call site emits:

```
warning: ~MOB: <MishkaChip> is not in the Mob tag whitelist — pass-through as :mishka_chip
```

We understand why: `Mob.Sigil` bakes `@known_tags` at **its own** compile time
from `priv/tags/{ios,android}.txt`, and our registration happens at **runtime**,
which a compile-time check cannot see. CHANGELOG 0.7.13 documents the warning as
expected, and the pass-through behaviour is clearly deliberate.

The difficulty is that it is a *warning*. On `--warnings-as-errors` — which this
project and many others build with — an expected warning is indistinguishable
from a real one, so the tag form becomes unusable and the kit has to be called
as plain functions instead:

```elixir
{chip(label: "Elixir", on_toggle: :pick)}   # compiles quietly, but is not a tag
```

## What we do today

We add our tags to `deps/mob/priv/tags/{android,ios}.txt` inside a fenced block
and then `mix deps.compile mob --force`, because `@known_tags` is baked at Mob's
compile time and writing the file alone changes nothing.

It works, but it edits a dependency in place, so `mix deps.get`, `deps.clean` and
a fresh clone all discard it, and each `MIX_ENV` needs its own recompile.

## The question

Is there a supported way for a UI kit to declare composite tags at **compile**
time?

We looked at the plugin manifest `ui_components` form. It registers expanders at
boot via `Mob.Plugins.register_composites/0`, but nothing in Mob writes
`priv/tags`, so the sigil still warns — as far as we can tell it solves
registration, not the whitelist.

Things that would each solve it, in rough order of how small they look:

1. **A config key** the sigil reads at compile time, e.g.
   `config :mob, extra_tags: ["MishkaChip", ...]`.
2. **Downgrading the unknown-tag warning** to something suppressible per
   call-site or per module (an attribute, or an opt-out), so it stays visible by
   default without failing a strict build.
3. **Having the plugin manifest's `ui_components` feed the whitelist**, so
   declaring a composite in the packaged way is enough.

Happy to send a PR for whichever fits the design — we just do not want to invent
a mechanism the framework already has, or one it would rather not have.
