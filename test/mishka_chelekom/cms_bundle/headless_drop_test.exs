defmodule MishkaChelekom.CmsBundle.HeadlessDropTest do
  @moduledoc """
  Every component of the shipped headless kit renders sample content the moment it is dropped on a
  page.

  The headless components ship no styling, and neither do their furnishings: a headless component
  carries no Tailwind class and no inline style, so a drop is bare markup and may well be zero-size
  (a slider, a splitter and a meter have no extent until the page styles them). What a drop must
  not be is empty markup: a segmented control with no options, a stepper with no steps, a table with
  no column headings. A furnishing in `priv/showcase_headless/` is the neutral sample content a drop
  arrives with, and this renders each component's drop through the runtime dispatcher and looks for
  it. The CMS editor gives such a node a floor on its canvas, so being small is the editor's concern,
  not the kit's.

  ## The drop

  What the CMS palette (`MishkaCmsBuilder.PaletteEntry.template/3`) writes, reduced to what decides
  whether anything is rendered. A declared furnishing wins outright: its attributes, its slot entries
  and its body. A component with none gets a line of text inside its `inner_block` (none for a
  progress, spinner or skeleton), two sample entries in a list slot the palette knows by name, an
  empty entry in any other required slot, and a placeholder for each required attribute.

  ## Content

  Read off the HTML, outside anything `hidden`, `display: none`, `sr-only` or clipped to a pixel:
  text; a control (an input, a textarea, a select, a button, a checkbox, a range, a file picker, an
  element that names itself a slider, a separator, a meter or a tree by its `role`); an image; an
  SVG shape with a stroke or a fill; or a chart's surface handed a series to draw. A class on an
  element is never content, and neither is a bare `div`.
  """
  use ExUnit.Case, async: false

  alias MishkaChelekom.Test.Runtime.DemoHarness

  @moduletag timeout: :timer.minutes(5)

  @bundle "priv/cms_ui_kits/chelekom_headless.json"

  # Holding nothing is the whole point of this one.
  @meant_to_hold_nothing ~w(chelekom-headless-visually-hidden)

  setup_all do
    components = @bundle |> File.read!() |> Jason.decode!() |> Map.fetch!("components")

    ExUnit.CaptureLog.capture_log(fn -> DemoHarness.compile_bundle(components) end)

    %{components: components}
  end

  test "every headless component dropped on a page renders its sample content", %{
    components: components
  } do
    assert length(components) > 100, "the headless bundle holds too few components to check"

    empty =
      for component <- components,
          component["name"] not in @meant_to_hold_nothing,
          source = drop(component),
          not content_html?(DemoHarness.render(source)),
          do: component["name"]

    assert empty == [],
           "these drop as an empty box; give each sample content (text, options, a placeholder) in " <>
             "a furnishing in priv/showcase_headless, never a class: " <> inspect(empty)
  end

  test "a furnished drop renders the component, not an error", %{components: components} do
    failed =
      for component <- components,
          get_in(component, ["extra", "furnishing"]),
          {:error, reason} <- [DemoHarness.render(drop(component))],
          do: {component["name"], reason |> String.split("\n") |> hd()}

    assert failed == []
  end

  test "the check tells sample content from an empty box" do
    assert content?(~s(<div><span>Volume</span></div>))
    assert content?(~s(<input type="text" placeholder="Your name">))
    assert content?(~s(<input type="text" maxlength="1" aria-label="Character 1 of 6">))
    assert content?(~s(<input type="radio" name="period" value="Week">))
    assert content?(~s(<div role="separator" class="chelekom-menu__separator "></div>))
    assert content?(~s(<div><span role="slider" aria-valuenow="40"></span></div>))
    assert content?(~s(<svg fill="none"><path d="M0 0" stroke="currentColor"></path></svg>))

    refute content?(~s(<div class="h-px w-full bg-current/15"></div>))
    refute content?(~s(<div class="chelekom-track"><div class="w-1/2 bg-current"></div></div>))
    refute content?(~s(<div><input type="hidden" name="period" value="Week"></div>))
    refute content?(~s(<svg fill="none"><path d="M0 0"></path></svg>))
    refute content?(~s(<div hidden>Closed</div><span class="sr-only">Label</span>))
  end

  ## The drop

  # The palette's starter text matched on the name's words; only "nothing" matters here.
  @silent_starters ~w(progress spinner skeleton)

  # The list slots the palette fills by name with sample entries, two each is enough to draw.
  @sample_slots ~w(item option radio checkbox tab panel slide control trigger content)

  # An `any` attribute the palette samples with a word rather than leaving blank.
  @text_names ~w(alt title label text name highlight)

  defp drop(component) do
    furnishing = get_in(component, ["extra", "furnishing"])
    furnished = (furnishing && furnishing["attrs"]) || %{}

    written =
      Enum.map_join(furnished, fn {name, value} -> " #{name}=#{written(value)}" end) <>
        Enum.map_join(seeded(component, Map.keys(furnished)), fn {name, value} ->
          " #{name}=#{value}"
        end)

    inside =
      case furnishing do
        %{} -> furnished_inside(component, furnishing)
        nil -> inferred_inside(component)
      end

    open = ~s(<.component component_name="#{component["name"]}" site="Global") <> written

    if inside == "", do: open <> " />", else: open <> ">" <> inside <> "</.component>"
  end

  defp furnished_inside(component, furnishing) do
    slots = furnishing["slots"] || []

    required_slots(component, Enum.map(slots, & &1["name"])) <>
      Enum.map_join(slots, &slot(&1["name"], &1["attrs"] || %{}, &1["body"] || "")) <>
      (furnishing["body"] || "")
  end

  defp inferred_inside(component) do
    samples =
      for slot <- component["slots"], slot["name"] in @sample_slots, n <- 1..2 do
        values = if requires_value?(slot), do: %{"value" => "sample-#{n}"}, else: %{}
        {slot["name"], Map.merge(slot_seeds(slot), values), "Sample #{n}"}
      end

    body =
      if takes_content?(component) and samples == [] and not silent?(component),
        do: "Your content here",
        else: ""

    required_slots(component, Enum.map(samples, &elem(&1, 0))) <>
      Enum.map_join(samples, fn {name, attrs, text} -> slot(name, attrs, text) end) <> body
  end

  defp required_slots(component, furnished) do
    for slot <- component["slots"],
        get_in(slot, ["opts", "required"]),
        slot["name"] not in ["inner_block" | furnished],
        into: "",
        do: slot(slot["name"], slot_seeds(slot), "")
  end

  defp slot(name, attrs, body) do
    written = Enum.map_join(attrs, fn {key, value} -> " #{key}=#{written(value)}" end)
    "<:#{name}#{written}>#{body}</:#{name}>"
  end

  defp slot_seeds(slot) do
    for attr <- slot["attrs"] || [], get_in(attr, ["opts", "required"]), into: %{} do
      {attr["name"], sample(attr)}
    end
  end

  defp requires_value?(slot),
    do:
      Enum.any?(
        slot["attrs"] || [],
        &(&1["name"] == "value" and get_in(&1, ["opts", "required"]))
      )

  defp takes_content?(component),
    do: Enum.any?(component["slots"], &(&1["name"] == "inner_block"))

  defp silent?(component) do
    words = String.split(component["name"], "-")
    Enum.any?(@silent_starters, &(&1 in words))
  end

  # A required attribute, an identity (`id`, `*_id`) the template reads, and one it reads with no
  # default — each the way the palette seeds it, so the component renders, or raises, as it would
  # on the canvas.
  defp seeded(component, skip) do
    template = component["template"] || ""

    for attr <- component["attrs"],
        attr["type"] not in ["global", "struct"],
        attr["name"] not in skip,
        seeded?(attr, attr["opts"] || %{}, template),
        do: {attr["name"], written(seed(attr, attr["opts"] || %{}))}
  end

  defp seeded?(_attr, %{"required" => true}, _template), do: true

  defp seeded?(%{"name" => name}, opts, template) do
    String.contains?(template, "@" <> name) and
      (identity?(name) or not Map.has_key?(opts, "default"))
  end

  defp identity?(name), do: name == "id" or String.ends_with?(name, "_id")

  defp seed(attr, opts) do
    cond do
      identity?(attr["name"]) and attr["type"] in ["string", "any"] ->
        "drop-#{System.unique_integer([:positive])}"

      opts["required"] == true ->
        sample(attr)

      true ->
        blank(attr)
    end
  end

  defp sample(%{"opts" => %{"values" => [first | _]}}) when not is_nil(first), do: first
  defp sample(%{"type" => "string", "name" => name} = attr), do: words(name, attr["opts"])
  defp sample(%{"type" => "any", "name" => name}) when name in @text_names, do: "Example"
  defp sample(attr), do: blank(attr)

  defp words(_name, %{"editor" => "icon"}), do: ""
  defp words(name, _opts) when name in ~w(src image poster), do: ""
  defp words(name, _opts) when name in ~w(href navigate patch link url), do: "#"
  defp words("value", _opts), do: "one"
  defp words("mask", _opts), do: "999-999"
  defp words("color", _opts), do: "#4f46e5"
  defp words(_name, _opts), do: "Example"

  defp blank(%{"type" => type}) when type in ["list", "keyword_list"], do: []
  defp blank(%{"type" => "map"}), do: %{}
  defp blank(%{"type" => "boolean"}), do: false
  defp blank(%{"type" => type}) when type in ["integer", "float", "pos_integer"], do: 3
  defp blank(_attr), do: ""

  # A word is an attribute; anything else is the expression the component takes. A furnishing's
  # `":label"` key is an atom, as the CMS reads it.
  defp written(value) when is_binary(value), do: ~s("#{value}")
  defp written(value), do: "{" <> inspect(atomized(value), limit: :infinity) <> "}"

  defp atomized(%{} = map), do: Map.new(map, fn {key, value} -> {key(key), atomized(value)} end)
  defp atomized(list) when is_list(list), do: Enum.map(list, &atomized/1)
  defp atomized(value), do: value

  defp key(":" <> name), do: String.to_atom(name)
  defp key(name), do: name

  ## Content

  defp content_html?({:ok, html}), do: content?(html)
  defp content_html?({:error, _reason}), do: false

  defp content?(html) do
    {"div", _attrs, nodes} = :mochiweb_html.parse("<div>" <> html <> "</div>")
    Enum.any?(nodes, &content_node?/1)
  end

  defp content_node?(text) when is_binary(text), do: String.trim(text) != ""

  defp content_node?({tag, attrs, children}) when is_binary(tag) do
    attrs = Map.new(attrs)

    cond do
      hidden?(tag, attrs) -> false
      native?(tag, attrs) or control?(attrs) or charted?(attrs) -> true
      true -> Enum.any?(children, &content_node?/1)
    end
  end

  defp content_node?(_comment_or_doctype), do: false

  @boxes ~w(script style template)
  @native ~w(input textarea select img video iframe progress meter hr button)
  @shapes ~w(path rect circle ellipse line polyline polygon)

  defp hidden?(tag, attrs) do
    style = String.replace(attrs["style"] || "", " ", "")

    tag in @boxes or Map.has_key?(attrs, "hidden") or attrs["type"] == "hidden" or
      style =~ "display:none" or style =~ "clip:rect(0" or
      Enum.any?(classes(attrs), &(&1 in ~w(sr-only chelekom-sr-only hidden)))
  end

  defp native?(tag, _attrs) when tag in @native, do: true

  defp native?(tag, attrs) when tag in @shapes,
    do: Enum.any?(["fill", "stroke"], &(attrs[&1] not in [nil, "none"]))

  defp native?(_tag, _attrs), do: false

  # An element that names itself a control, which is what a headless slider, splitter, meter or
  # separator is until the page styles it: markup with a role, however small it draws.
  @roles ~w(slider separator meter progressbar scrollbar spinbutton switch checkbox radio textbox
            searchbox combobox listbox option tab tablist tree treeitem menuitem button link img)

  defp control?(attrs), do: attrs["role"] in @roles

  defp classes(attrs), do: String.split(attrs["class"] || "")

  # A chart's engine draws the option it is handed on the page; the markup only carries it.
  defp charted?(%{"data-option" => option}) do
    case Jason.decode(option) do
      {:ok, %{"series" => [_ | _]}} -> true
      _no_series -> false
    end
  end

  defp charted?(_attrs), do: false
end
