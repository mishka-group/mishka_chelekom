defmodule MishkaChelekom.CmsBundle.Showcase do
  @moduledoc """
  Hand-authored, real-world examples that OVERLAY the harvested ones.

  ## Why a second place rather than a better harvest

  `MishkaChelekom.CmsBundle.Examples` selects for OPTION COVERAGE — its own
  comment says "one example per distinct option VALUE" — and that is the
  right thing for it to do. A CMS reading the bundle needs to know which
  invocation demonstrates `variant="outline"` and which demonstrates
  `color="danger"`, and the harvest answers that from the docs pages
  without anybody writing anything by hand.

  But it is the wrong answer to a different question. A page builder's
  examples modal is asked "show me a finished one I can put on my site
  and edit", and option coverage answers that with a hundred rows reading
  "Banner Default variant natural". The builder's own wizard already
  offers every option with a live preview, so the modal is spending its
  space on a question that is already answered better elsewhere.

  So the harvest stays exactly as it is — same code, same tests, same
  `extra.demo_examples` — and anything authored here is laid over the top
  for the components that have one. A component with no showcase file is
  untouched and ships the harvest as before.

  ## The file

  One JSON file per component under `priv/showcase/`, named for the
  component:

      priv/showcase/chelekom-card.json

      {
        "name": "chelekom-card",
        "furnishing": {
          "body": "<.component component_name=\\"chelekom-card-title\\" site=\\"Global\\">…</.component>",
          "slots": []
        },
        "examples": [
          {
            "label": "Pricing card with feature list",
            "source": "<.component component_name=\\"chelekom-card\\" …>…</.component>",
            "non_default_options": {"variant": "outline"}
          }
        ]
      }

  `furnishing` is what a page builder places on a plain drag-and-drop,
  when the reader has opened neither the examples modal nor the wizard —
  see `MishkaCmsCore.Builder.Furnishing`, which validates this shape on
  the consumer side. `examples` are the finished blocks, three to five of
  them, labelled for what they ARE rather than for the option they set.

  `non_default_options` becomes `requires`, in the same shape the harvest
  emits it, so a minimal install can hide an example whose variant it did
  not ship.

  ## Untrusted on purpose

  A showcase file is content, edited by hand and often by somebody who is
  not watching the export run. A malformed one is skipped and named
  rather than raising, so one bad file costs its own component and the
  bundle still ships.

  ## Pictures

  An example — authored in `priv/showcase/` or harvested from the documentation's demos — draws
  `/images/<file>`, a path no CMS serves. `priv/showcase/media/` holds the kit's samples, in groups
  named by their prefix:

    * `scene-*` — pictures of places and things;
    * `person-*` — pictures of people;
    * `mark-*` — a logo;
    * `video-*.url` — the address of a sample video, which is too big to write inline.

  Every `/images/<file>` in an example, a demo example or a furnishing becomes:

    * the file itself, as a `data:` address, when `media/` holds it;
    * otherwise a sample of its kind — a video becomes a `video-*` address, a vector (`.svg`) a
      `mark-*`, a picture whose tag is round or an avatar's (`rounded-full`, `avatar`) a `person-*`,
      any other picture a `scene-*` — picked by the file's name, so one file is always one sample.

  A path no sample answers for is left as it is.
  """

  require Logger

  @doc """
  Lays authored examples over harvested ones, for every component that has a
  showcase file, then writes every `/images/<file>` any example draws as a
  sample the kit ships in `media/` — see "Pictures" below.

  Returns `components` unchanged when the directory does not exist — a kit
  that has authored nothing is not in an error state.
  """
  @spec overlay([map()], Path.t()) :: [map()]
  def overlay(components, dir) do
    case File.dir?(dir) do
      false -> components
      true -> components |> apply_index(index(dir)) |> with_samples(dir)
    end
  end

  defp apply_index(components, index) when map_size(index) == 0, do: components

  defp apply_index(components, index) do
    Enum.map(components, fn component ->
      case Map.get(index, component["name"]) do
        nil -> component
        showcase -> authored(component, showcase)
      end
    end)
  end

  # The harvested `demo_examples` are deliberately left alone: they are what the
  # kit's own demo harness renders, and nothing about authoring a nicer example
  # makes them less true.
  defp authored(component, showcase) do
    examples = Enum.with_index(showcase["examples"], &entry(&1, &2, component))

    extra =
      (component["extra"] || %{})
      |> Map.put("examples", examples)
      |> put_furnishing(showcase["furnishing"])

    component
    |> Map.put("examples", Enum.map(examples, & &1["source"]))
    |> Map.put("extra", extra)
  end

  defp put_furnishing(extra, furnishing) when is_map(furnishing),
    do: Map.put(extra, "furnishing", furnishing)

  defp put_furnishing(extra, _absent), do: extra

  # The same shape `Examples.build/5` emits, so a consumer cannot tell an
  # authored entry from a harvested one by its structure — only by its quality.
  # `section` is the docs-page heading a harvested example sat under; an authored
  # one has no page to sit on.
  defp entry(example, index, component) do
    %{
      "source" => example["source"],
      "label" => example["label"],
      "section" => nil,
      "base" => index == 0,
      "requires" => requires(example["source"], component)
    }
  end

  # DERIVED FROM THE MARKUP, never from anything the author writes alongside it —
  # the rule `Examples.tag/3` already follows, for the same reason. An author
  # asked to list the non-default options they used answers in prose ("large —
  # hero-scale numerals so the band reads at arm's length"), and that lands in
  # `requires` as an axis no install can satisfy, hiding the example everywhere.
  #
  # The markup cannot be wrong about itself. An attr value outside the
  # component's own universe is a Tailwind passthrough rather than an option, so
  # it is dropped exactly as the harvest drops it.
  @axes ~w(variant color size padding space rounded border)

  defp requires(source, component) do
    universe = MishkaChelekom.CmsBundle.Examples.option_universe(component)
    attrs = root_attrs(source)

    axes =
      for axis <- @axes,
          value = Map.get(attrs, axis),
          is_binary(value),
          allowed = Map.get(universe, axis),
          allowed && MapSet.member?(allowed, value),
          into: %{},
          do: {axis, [value]}

    put_components(axes, dispatches(source, component["name"]))
  end

  # The OTHER half of `requires`, and the half an authored example needs more than a harvested one:
  # a finished block composes. A pricing card is a card, a title, a badge, a content area, a footer
  # and a button — and an install that took the card without the badge would render it with a hole
  # in it. Naming what a block dispatches to is what lets a consumer hide it instead.
  #
  # The same shape and the same rule `Examples.tag/3` follows, including dropping the component's own
  # name: an example of a card is expected to contain a card.
  defp put_components(axes, []), do: axes
  defp put_components(axes, components), do: Map.put(axes, "components", components)

  defp dispatches(source, self_name) do
    ~r/component_name="([^"]+)"/
    |> Regex.scan(source)
    |> Enum.map(&List.last/1)
    |> Enum.reject(&(&1 == self_name))
    |> Enum.uniq()
  end

  # The attributes of the OUTERMOST component invocation. A block whose root is a
  # plain `<div>` wrapper pins nothing, which is correct: the options inside it
  # belong to its children, and a minimal install that drops one of those still
  # renders the block rather than losing it whole.
  defp root_attrs(source) do
    case MishkaChelekom.CmsBundle.Heex.tokenize(source, file: "showcase") do
      {:ok, tokens} ->
        Enum.find_value(tokens, %{}, fn
          {:local_component, "component", attrs, _meta} ->
            for {name, {:string, value, _}, _} <- attrs, into: %{}, do: {name, value}

          _token ->
            nil
        end)

      {:error, _reason} ->
        %{}
    end
  end

  # A leading underscore marks a file that is ABOUT the showcase rather than part
  # of it — `_schema.json`, which authors validate against. Without this it would
  # be read as a component's showcase, fail validation, and log a warning on every
  # export.
  defp index(dir) do
    dir
    |> Path.join("*.json")
    |> Path.wildcard()
    |> Enum.reject(&String.starts_with?(Path.basename(&1), "_"))
    |> Enum.flat_map(&read/1)
    |> Map.new()
  end

  defp read(path) do
    with {:ok, raw} <- File.read(path),
         {:ok, json} <- Jason.decode(raw),
         :ok <- validate(json) do
      [{json["name"], json}]
    else
      error ->
        Logger.warning("[Showcase] skipped #{Path.basename(path)} — #{inspect(error)}")
        []
    end
  end

  # Shape only, in the spirit of `MishkaCmsCore.UiKit.Contract`: a name to attach
  # it to, and examples that are at least a labelled source. What the source SAYS
  # is the author's business and no schema can check it.
  defp validate(%{"name" => name, "examples" => examples})
       when is_binary(name) and is_list(examples) and examples != [] do
    case Enum.all?(examples, &example?/1) do
      true -> :ok
      false -> {:error, :malformed_example}
    end
  end

  defp validate(_json), do: {:error, :missing_name_or_examples}

  defp example?(%{"source" => source, "label" => label})
       when is_binary(source) and is_binary(label),
       do: String.trim(source) != "" and String.trim(label) != ""

  defp example?(_example), do: false

  @pictures %{
    ".svg" => "image/svg+xml",
    ".png" => "image/png",
    ".jpg" => "image/jpeg",
    ".jpeg" => "image/jpeg",
    ".webp" => "image/webp",
    ".gif" => "image/gif",
    ".avif" => "image/avif"
  }

  @videos ~w(.mp4 .webm .ogg .ogv .mov .m4v)

  @path ~r{/images/[A-Za-z0-9_.\-]+}

  defp with_samples(components, dir) do
    samples = samples(Path.join(dir, "media"))

    case map_size(samples.files) do
      0 -> components
      _held -> Enum.map(components, &component(&1, samples))
    end
  end

  defp component(component, samples) do
    component
    |> Map.new(fn
      {"examples", examples} -> {"examples", written(examples, samples)}
      {"extra", %{} = extra} -> {"extra", Map.new(extra, &extra(&1, samples))}
      other -> other
    end)
  end

  defp extra({key, value}, samples) when key in ["examples", "demo_examples", "furnishing"],
    do: {key, written(value, samples)}

  defp extra(other, _samples), do: other

  defp samples(dir) do
    files = Path.wildcard(Path.join(dir, "*"))

    pictures =
      for path <- files,
          type = Map.get(@pictures, String.downcase(Path.extname(path))),
          {:ok, bytes} <- [File.read(path)],
          into: %{},
          do: {Path.basename(path), "data:#{type};base64," <> Base.encode64(bytes)}

    videos =
      for path <- files,
          Path.extname(path) == ".url",
          {:ok, text} <- [File.read(path)],
          address = String.trim(text),
          String.starts_with?(address, "https://"),
          into: %{},
          do: {Path.basename(path, ".url"), address}

    %{
      files: Map.new(pictures, fn {name, data} -> {"/images/" <> name, data} end),
      scene: group(pictures, "scene-"),
      person: group(pictures, "person-"),
      mark: group(pictures, "mark-"),
      video: group(videos, "video-")
    }
  end

  defp group(held, prefix) do
    for {name, value} <- Enum.sort(held), String.starts_with?(name, prefix), do: value
  end

  defp written(%{} = map, samples), do: Map.new(map, fn {k, v} -> {k, written(v, samples)} end)
  defp written(list, samples) when is_list(list), do: Enum.map(list, &written(&1, samples))
  defp written(text, samples) when is_binary(text), do: text(text, samples)
  defp written(other, _samples), do: other

  # From the last path back, so the places of the ones before it stay where they were.
  defp text(text, samples) do
    @path
    |> Regex.scan(text, return: :index)
    |> Enum.reverse()
    |> Enum.reduce(text, fn [{at, length}], text ->
      path = binary_part(text, at, length)
      after_at = at + length

      binary_part(text, 0, at) <>
        sample(path, tag(text, at, after_at), samples) <>
        binary_part(text, after_at, byte_size(text) - after_at)
    end)
  end

  # The tag the path is written in: from the `<` before it to the `>` after it.
  defp tag(text, at, after_at) do
    before = text |> binary_part(0, at) |> String.split("<") |> List.last()

    rest =
      text |> binary_part(after_at, byte_size(text) - after_at) |> String.split(">", parts: 2)

    before <> hd(rest)
  end

  defp sample(path, tag, samples) do
    extension = path |> Path.extname() |> String.downcase()

    case {Map.fetch(samples.files, path), kind(extension, tag)} do
      {{:ok, data}, _kind} -> data
      {:error, nil} -> path
      {:error, kind} -> pick(Map.fetch!(samples, kind), path)
    end
  end

  defp kind(extension, _tag) when extension in @videos, do: :video
  defp kind(".svg", _tag), do: :mark

  defp kind(extension, tag) when is_map_key(@pictures, extension) do
    case String.contains?(tag, ["rounded-full", "avatar"]) do
      true -> :person
      false -> :scene
    end
  end

  defp kind(_extension, _tag), do: nil

  defp pick([], path), do: path
  defp pick(group, path), do: Enum.at(group, :erlang.phash2(path, length(group)))
end
