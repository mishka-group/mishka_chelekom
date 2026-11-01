defmodule MishkaChelekom.CmsBundle.PhrasingInButtonAndLabelTest do
  @moduledoc """
  A `<button>` and a `<label>` hold phrasing content only, so no styled component draws a `<div>`,
  `<p>`, list or other block inside one.

  The HTML standard gives both elements the phrasing content model
  (https://html.spec.whatwg.org/multipage/dom.html#phrasing-content). A CMS that holds a button
  and a label to it refuses to drop the kit's tabs, accordion, combobox, cards, toggle or file
  dropzone next to markup of its own while their triggers and labels are made of blocks.

  This renders the components that draw content inside a button or a label through the runtime
  dispatcher, the way a CMS page does, so a component one of them draws inside the button counts
  too: the tab's badge is a `<span>` for that reason. The HTML is parsed and every element below a
  `<button>` or a `<label>` is looked up in the standard's list. An `<svg>` is phrasing content and
  its shapes are not asked.
  """
  use ExUnit.Case, async: false

  alias MishkaChelekom.Test.Runtime.DemoHarness

  @moduletag timeout: :timer.minutes(5)

  @bundle "priv/cms_ui_kits/chelekom.json"

  @hosts ~w(button label)

  @phrasing ~w(a abbr area audio b bdi bdo br button canvas cite code data datalist del dfn em
    embed i iframe img input ins kbd label link map mark math meta meter noscript object output
    picture progress q ruby s samp script select slot small span strong sub sup svg template
    textarea time u var video wbr)

  @upload %Phoenix.LiveView.UploadConfig{name: :avatar, ref: "phx-avatar", max_entries: 1}

  # `{label, markup, assigns}`: each draws content inside a button or a label.
  @cases [
    {"a tab with a badge and an icon",
     ~S"""
     <.component component_name="chelekom-tabs" site="Global" id="tabs-a">
       <:tab badge="3" icon="hero-home">One</:tab>
       <:tab>Two</:tab>
       <:panel>First</:panel>
       <:panel>Second</:panel>
     </.component>
     """, %{}},
    {"a scrollable tab with a badge",
     ~S"""
     <.component component_name="chelekom-tabs" site="Global" id="tabs-b" scrollable>
       <:tab badge="new" badge_color="success">One</:tab>
       <:tab>Two</:tab>
       <:panel>First</:panel>
       <:panel>Second</:panel>
     </.component>
     """, %{}},
    {"an accordion item with an icon, a title and a description",
     ~S"""
     <.component component_name="chelekom-accordion" site="Global" id="accordion-a">
       <:item id="item-a" title="Title" description="Description" icon="hero-home">Body</:item>
       <:item id="item-b" title="Other">Body</:item>
     </.component>
     """, %{}},
    {"a combobox",
     ~S"""
     <.component component_name="chelekom-combobox" site="Global" id="combobox-a" name="a" placeholder="Pick">
       <:start_section>Start</:start_section>
       <:option value="one">One</:option>
     </.component>
     """, %{}},
    {"a multiple combobox",
     ~S"""
     <.component component_name="chelekom-combobox" site="Global" id="combobox-b" name="b" multiple placeholder="Pick">
       <:start_section>Start</:start_section>
       <:option value="one">One</:option>
     </.component>
     """, %{}},
    {"a radio card with an icon, a title, a description and content",
     ~S"""
     <.component component_name="chelekom-radio-card" site="Global" id="radio-a" name="plan">
       <:radio value="a" icon="hero-home" title="Title" description="Description">Content</:radio>
       <:radio value="b" title="Other" description="Other description" />
     </.component>
     """, %{}},
    {"a checkbox card with an icon, a title, a description and content",
     ~S"""
     <.component component_name="chelekom-checkbox-card" site="Global" id="checkbox-a" name="plans[]">
       <:checkbox value="a" icon="hero-home" title="Title" description="Description">Content</:checkbox>
       <:checkbox value="b" title="Other" description="Other description">More</:checkbox>
     </.component>
     """, %{}},
    {"a toggle field",
     ~S"""
     <.component component_name="chelekom-toggle-field" site="Global" id="toggle-a" name="a" label="Label" />
     """, %{}},
    {"a file dropzone",
     ~S"""
     <.component component_name="chelekom-file-field" site="Global" id="file-a" dropzone target={:avatar} uploads={@uploads} dropzone_title="Drop it" dropzone_description="Here" />
     """, %{"uploads" => %{avatar: @upload}}},
    {"an image dropzone",
     ~S"""
     <.component component_name="chelekom-file-field" site="Global" id="file-b" dropzone dropzone_type="image" target={:avatar} uploads={@uploads} />
     """, %{"uploads" => %{avatar: @upload}}}
  ]

  setup_all do
    components = @bundle |> File.read!() |> Jason.decode!() |> Map.fetch!("components")

    ExUnit.CaptureLog.capture_log(fn -> DemoHarness.compile_bundle(components) end)

    :ok
  end

  for {label, markup, assigns} <- @cases do
    test "#{label} holds phrasing content in its buttons and labels" do
      assert {:ok, html} = DemoHarness.render(unquote(markup), unquote(Macro.escape(assigns)))
      assert html =~ ~r/<(button|label)\b/, "the case draws no button or label"

      assert non_phrasing(html) == []
    end
  end

  test "a badge is a span, so it fits in a button, a label or a paragraph" do
    markup =
      ~S|<.component component_name="chelekom-badge" site="Global" dismiss>New</.component>|

    assert {:ok, html} = DemoHarness.render(markup)
    assert {"span", _attrs, _children} = html |> parse() |> List.first()
  end

  test "the check finds a block in a button and in a label" do
    assert non_phrasing(~s|<button><div>Title</div></button>|) == [{"button", "div"}]
    assert non_phrasing(~s|<label><span><p>Text</p></span></label>|) == [{"label", "p"}]
    assert non_phrasing(~s|<button><span>Title</span><svg><path d="M0 0"/></svg></button>|) == []
    assert non_phrasing(~s|<div><button>Title</button></div>|) == []
  end

  # `{host, tag}` of every element below a button or a label that is not phrasing content.
  defp non_phrasing(html), do: html |> parse() |> Enum.flat_map(&below(&1, nil))

  defp parse(html) do
    case :mochiweb_html.parse("<div>" <> html <> "</div>") do
      {"div", _attrs, nodes} -> nodes
    end
  end

  defp below({"svg", _attrs, _children}, _host), do: []

  defp below({tag, _attrs, children}, host) do
    own =
      if host && tag not in @phrasing, do: [{host, tag}], else: []

    next = if tag in @hosts, do: tag, else: host

    own ++ Enum.flat_map(children, &below(&1, next))
  end

  defp below(_text_or_comment, _host), do: []
end
