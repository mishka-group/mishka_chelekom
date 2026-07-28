defmodule MishkaMob.ShowcaseTest do
  # async: false — the registry and composite registry are global (persistent_term).
  use Mob.ScreenCase, async: false

  alias MishkaMob.Components.MishkaMark
  alias MishkaMob.Showcase
  alias MishkaMob.Showcase.{ComponentScreen, GalleryScreen}

  setup do
    # Exactly what the app registers at boot — one catalog, no drift.
    Showcase.reset()
    Showcase.register_all()
    :ok
  end

  defp expanded(view), do: Mob.Composite.expand(tree(view), self())
  defp drawer_node(view), do: find(view, :mishka_drawer)

  # The "Inside inputs" token rows, as lists of the pills in each. A row here is
  # a :row whose DIRECT children are pills — the wrapper Column and the outer
  # example rows both contain pills through their descendants and would
  # otherwise match too.
  defp token_rows(tree) do
    tree
    |> find_all(:row)
    |> Enum.map(fn row ->
      Enum.filter(row.children, &(&1.props[:corner_radius] == :radius_pill))
    end)
    |> Enum.reject(fn pills ->
      pills == [] or not Enum.all?(pills, &(text(&1) =~ "Item "))
    end)
  end

  describe "registry" do
    test "register + lookup augments the entry with its module" do
      entry = Showcase.get(:drawer)
      assert entry.slug == :drawer
      assert entry.name == "Drawer"
      assert entry.category == "Overlays"
      assert entry.module == MishkaMob.Showcase.Components.Drawer
    end

    test "by_category groups every catalog entry, categories alphabetical" do
      grouped = Showcase.by_category()
      categories = Enum.map(grouped, fn {category, _} -> category end)

      assert categories == Enum.sort(categories)

      # each component lands under the category its own entry declares
      for module <- Showcase.modules() do
        entry = module.entry()
        {_category, entries} = Enum.find(grouped, fn {c, _} -> c == entry.category end)

        assert Enum.any?(entries, &(&1.slug == entry.slug)),
               "#{inspect(module)} is missing from #{entry.category}"
      end

      # every registered component lands in exactly one group
      slugs = Enum.flat_map(grouped, fn {_, entries} -> Enum.map(entries, & &1.slug) end)
      assert length(slugs) == length(Showcase.modules())
      assert Enum.uniq(slugs) == slugs
    end

    test "the catalog registers a composite tag for every gallery entry" do
      # A page may document several components (a close button IS an action
      # icon), so tags outnumber pages — but no page may have none.
      assert length(Showcase.composites()) >= length(Showcase.modules())

      # each component module actually exports the expander the catalog names.
      # ensure_loaded? first: function_exported?/3 answers false for a module
      # that simply has not been loaded yet, which made this assertion depend on
      # whichever earlier test happened to reference the module.
      for {_tag, module} <- Showcase.composites() do
        assert Code.ensure_loaded?(module), "#{inspect(module)} does not exist"
        assert function_exported?(module, :expand, 3), "#{inspect(module)} is missing expand/3"
      end
    end

    test "composite tags and their components are each registered once" do
      {tags, modules} = Enum.unzip(Showcase.composites())

      assert Enum.uniq(tags) == tags,
             "duplicate composite tag: #{inspect(tags -- Enum.uniq(tags))}"

      assert Enum.uniq(modules) == modules,
             "component registered twice: #{inspect(modules -- Enum.uniq(modules))}"
    end

    test "every component module with an expander is in the catalog" do
      # The gap this closes: a companion component (Burger, CloseButton,
      # PillsInput…) is easy to write, test and ship without ever giving it a
      # tag, leaving it unusable from `~MOB` markup. This fails when that
      # happens instead of leaving it to be noticed by an app author.
      registered = Showcase.composites() |> Enum.map(&elem(&1, 1)) |> MapSet.new()

      unregistered =
        "lib/mishka_mob/components/*.ex"
        |> Path.wildcard()
        |> Enum.map(fn path ->
          Module.concat([
            "MishkaMob.Components",
            path |> Path.basename(".ex") |> Macro.camelize()
          ])
        end)
        |> Enum.filter(&(Code.ensure_loaded?(&1) and function_exported?(&1, :expand, 3)))
        |> Enum.reject(&MapSet.member?(registered, &1))

      assert unregistered == [], "not in the catalog: #{inspect(unregistered)}"
    end

    test "every catalog entry renders its own gallery page" do
      for module <- Showcase.modules() do
        slug = module.entry().slug
        view = mount_screen(ComponentScreen, %{slug: slug})

        assert assigns(view).entry.slug == slug
        # :canvas is missing from mob 0.7.20's priv/tags whitelist, but both
        # bridges render it (MobBridge.kt "canvas" -> MobCanvas, and the same
        # branch in mob's ios/mob_nif.m) and Mob.UI.canvas/1 is a public API.
        # The whitelist is stale, not the node.
        assert_renderable(expanded(view), extra: [:canvas])
        refute Enum.empty?(module.examples()), "#{inspect(module)} has no examples"
      end
    end

    test "focus and blur reach the component, and are NOT taps" do
      # The bug this pins: mob_send_focus emits {:focus, tag}, not {:tap, tag}.
      # Without clauses for the real shape both events fell through the catch-all
      # and vanished, so a field that genuinely had focus never told the screen —
      # and the OTP caret, which is drawn from that flag, never appeared.
      view = mount_screen(ComponentScreen, %{slug: :otp_field})

      refute assigns(view).otp_focused

      focused = render_info(view, {:focus, :otp_focus})
      assert assigns(focused).otp_focused

      blurred = render_info(focused, {:blur, :otp_blur})
      refute assigns(blurred).otp_focused
    end

    test "a focus event for one field does not light up another" do
      # Each example holds its own flag; one shared flag would draw a caret in
      # every OTP on the page as soon as any of them was tapped.
      view =
        ComponentScreen
        |> mount_screen(%{slug: :otp_field})
        |> render_info({:focus, :otp_masked_focus})

      assert assigns(view).otp_masked_focused
      refute assigns(view).otp_focused
      refute assigns(view).otp_ref_focused
    end

    test "unknown slug returns nil" do
      assert Showcase.get(:nope) == nil
    end
  end

  describe "GalleryScreen" do
    test "lists registered components and is renderable" do
      view = mount_screen(GalleryScreen)

      # Card previews may draw on a canvas — see the note above.
      assert_renderable(view, extra: [:canvas])
      assert text(view) =~ "Components"
      # a tappable row per component, labelled by name
      assert find(view, :button, text: "Drawer")
    end
  end

  describe "ComponentScreen" do
    test "loads the entry from the slug param and renders its examples + code" do
      view = mount_screen(ComponentScreen, %{slug: :drawer})

      assert assigns(view).entry.slug == :drawer
      assert assigns(view).drawer_open? == false
      assert_renderable(expanded(view))
      assert text(view) =~ "Open from any side"
      assert text(view) =~ "Rounded bottom sheet"
      # the example code is shown verbatim as text
      assert text(view) =~ "MishkaDrawer"
    end

    test "opening delegates to the component and stacks the overlay" do
      view =
        ComponentScreen
        |> mount_screen(%{slug: :drawer})
        |> render_info({:tap, {:open, :right, :default}})

      assert assigns(view).drawer_open? == true
      assert assigns(view).drawer_side == :right

      # "About" appears only in the drawer body — every other menu label also
      # shows up in an example's code block, so it would not prove the overlay.
      assert text(expanded(view)) =~ "About"
      assert_renderable(expanded(view))
    end

    test "menu rows are left-aligned tappable boxes, not centred buttons" do
      view =
        ComponentScreen
        |> mount_screen(%{slug: :drawer})
        |> render_info({:tap, {:open, :right, :default}})

      children = drawer_node(view).children
      rows = Enum.filter(children, &(&1.type == :box))

      # A Material Button centres its label; a tappable Box lets the row lay the
      # icon + label out from the leading edge.
      refute Enum.any?(children, &(&1.type == :button))
      assert length(rows) == 3
      assert Enum.all?(rows, &(&1.props[:on_tap] != nil))
      assert Enum.all?(rows, &(&1.props[:fill_width] == true))
    end

    test "every example opens a distinct, visible drawer variant" do
      base = mount_screen(ComponentScreen, %{slug: :drawer})

      sides = base |> render_info({:tap, {:open, :right, :default}}) |> drawer_node()
      assert sides.props.open == true
      assert sides.props.side == :right
      refute Map.has_key?(sides.props, :corner_radius)

      sheet = base |> render_info({:tap, {:open, :bottom, :sheet}}) |> drawer_node()
      assert sheet.props.open == true
      assert sheet.props.side == :bottom
      assert sheet.props.corner_radius == :radius_lg

      custom = base |> render_info({:tap, {:open, :left, :custom}}) |> drawer_node()
      assert custom.props.open == true
      assert custom.props.side == :left
      assert custom.props.header == false

      colors = base |> render_info({:tap, {:open, :left, :colors}}) |> drawer_node()
      assert colors.props.open == true
      assert colors.props.background == 0xFF7C3AED
      assert colors.props.scrim_color == 0x992E1065
    end

    test "the custom-chrome variant supplies its own account header (header: false)" do
      view =
        ComponentScreen
        |> mount_screen(%{slug: :drawer})
        |> render_info({:tap, {:open, :left, :custom}})

      # the built-in title/✕ is off; a bespoke account card is rendered instead
      assert drawer_node(view).props.header == false
      assert text(expanded(view)) =~ "Shahryar"
      assert text(expanded(view)) =~ "shahryar@mishka.tools"

      # the panel must keep the default :surface background — tinting it
      # :surface_raised matched the rows and made them invisible
      refute Map.has_key?(drawer_node(view).props, :background)
    end

    test "declares a props reference that the ComponentScreen renders" do
      props = MishkaMob.Showcase.Components.Drawer.props()
      assert length(props) >= 8
      assert Enum.all?(props, &is_binary(&1.name))
      assert Enum.any?(props, &(&1.name == "side"))

      view = mount_screen(ComponentScreen, %{slug: :drawer})
      assert text(view) =~ "Props"
      assert text(view) =~ "scrim_color"
      assert text(view) =~ "on_close"
    end

    test "standalone example triggers are full-width, not weight (so they don't collapse)" do
      view = mount_screen(ComponentScreen, %{slug: :drawer})
      open_sheet = find(view, :button, text: "Open bottom sheet")

      assert open_sheet.props.fill_width == true
      refute Map.has_key?(open_sheet.props, :weight)
    end

    test "the drawer ships a bespoke card face (not the generic skeleton)" do
      preview = MishkaMob.Showcase.Components.Drawer.card_preview()
      assert preview.type == :column
      # the mini drawer's side panel is a fixed-width box
      assert find(preview, :box, width: 66)
    end

    test "closing hides the overlay again" do
      view =
        ComponentScreen
        |> mount_screen(%{slug: :drawer})
        |> render_info({:tap, {:open, :bottom, :sheet}})
        |> render_info({:tap, :close_drawer})

      assert assigns(view).drawer_open? == false
      refute text(expanded(view)) =~ "About"
    end

    test "the Accordion page renders its examples, panels and props" do
      view = mount_screen(ComponentScreen, %{slug: :accordion})

      assert assigns(view).entry.slug == :accordion
      assert_renderable(expanded(view))
      assert text(view) =~ "One at a time"
      assert text(view) =~ "Multiple open"
      assert text(view) =~ "Props"
      # the seeded open panel's body is visible; a closed one's is not
      assert text(expanded(view)) =~ "A component library for Phoenix"
      refute text(expanded(view)) =~ "expands to SwiftUI"
    end

    test "each Accordion example keeps an independent open set" do
      view = mount_screen(ComponentScreen, %{slug: :accordion})
      multi_before = assigns(view).acc_multi
      locked_before = assigns(view).acc_locked

      view = render_info(view, {:tap, {:toggle_faq, :styled}})

      # single-open mode replaced the seeded panel …
      assert assigns(view).acc_faq == [:styled]
      # … and left every other example alone
      assert assigns(view).acc_multi == multi_before
      assert assigns(view).acc_locked == locked_before
    end

    test "the Accordion examples apply their own multiple / collapsible modes" do
      base = mount_screen(ComponentScreen, %{slug: :accordion})

      multi = render_info(base, {:tap, {:toggle_multi, :hot}})
      assert assigns(multi).acc_multi == [:beam, :native, :hot]

      # collapsible: false — tapping the only open panel must not close it
      locked = render_info(base, {:tap, {:toggle_locked, :always}})
      assert assigns(locked).acc_locked == [:always]

      # …but another item still takes the slot
      moved = render_info(base, {:tap, {:toggle_locked, :other}})
      assert assigns(moved).acc_locked == [:other]
    end

    test "the disabled Accordion item renders but wires no tap" do
      view = mount_screen(ComponentScreen, %{slug: :accordion})

      taps =
        expanded(view)
        |> find_all(:box)
        |> Enum.map(& &1.props[:on_tap])
        |> Enum.reject(&is_nil/1)

      assert text(view) =~ "I am disabled"
      assert Enum.any?(taps, &match?({_pid, {:toggle_disabled, :ok}}, &1))
      refute Enum.any?(taps, &match?({_pid, {:toggle_disabled, :nope}}, &1))
    end

    test "a change event round-trips through handle_change/3" do
      view = mount_screen(ComponentScreen, %{slug: :switch})
      assert assigns(view).sw_bluetooth == false

      view = render_info(view, {:change, :bluetooth, true})
      assert assigns(view).sw_bluetooth == true

      # the switch now renders in its new state
      toggles =
        expanded(view) |> find_all(:toggle) |> Enum.filter(&(&1.props[:on_change] == :bluetooth))

      assert Enum.all?(toggles, &(&1.props.value == true))
    end

    test "an unknown change tag is ignored rather than crashing the screen" do
      view = mount_screen(ComponentScreen, %{slug: :switch})
      before = assigns(view)

      view = render_info(view, {:change, :nope, true})

      assert assigns(view).sw_wifi == before.sw_wifi
      assert assigns(view).sw_bluetooth == before.sw_bluetooth
    end

    test "the disabled switch example wires no handler" do
      view = mount_screen(ComponentScreen, %{slug: :switch})

      disabled =
        expanded(view) |> find_all(:toggle) |> Enum.reject(&Map.has_key?(&1.props, :on_change))

      # the two "Locked" switches, and they keep their rendered state
      assert length(disabled) == 2
      assert Enum.map(disabled, & &1.props.value) == [true, false]
    end

    test "the Pill page renders every example and its props" do
      view = mount_screen(ComponentScreen, %{slug: :pill})

      assert_renderable(expanded(view))

      for heading <- ["Inside inputs", "Tappable", "Plain", "Colour", "Disabled", "Props"] do
        assert text(view) =~ heading
      end
    end

    test "every pill on the page hugs its label" do
      # The bug that made the page unusable: MobBridge never read fill_width for
      # a Box, so a pill filled the row and the "Inside inputs" example showed
      # one token per line. Both halves were needed; this guards the Elixir one
      # for EVERY pill on the page, including the ones inside examples.
      pills =
        ComponentScreen
        |> mount_screen(%{slug: :pill})
        |> expanded()
        |> find_all(:box)
        |> Enum.filter(&(&1.props[:corner_radius] == :radius_pill))

      assert length(pills) > 10
      assert Enum.all?(pills, &(&1.props[:fill_width] == false))
    end

    test "the tokens wrap into rows rather than one long line" do
      view = mount_screen(ComponentScreen, %{slug: :pill})

      # Ten tokens chunked three to a row — the wrap is declared, because Mob
      # reports no geometry back and nothing can ask how many fit.
      assert length(assigns(view).pill_tokens) == 10
      assert text(expanded(view)) =~ "Item 0"
      assert text(expanded(view)) =~ "Item 9"

      assert Enum.map(token_rows(expanded(view)), &length/1) == [3, 3, 3, 1]
    end

    test "removing a token drops exactly that one" do
      view =
        ComponentScreen
        |> mount_screen(%{slug: :pill})
        |> render_info({:tap, {:token_drop, :item_3}})

      refute :item_3 in assigns(view).pill_tokens
      assert length(assigns(view).pill_tokens) == 9
      refute text(expanded(view)) =~ "Item 3"
      assert text(expanded(view)) =~ "Item 4"

      # …and the rows reflow: 9 tokens is three full rows, not three-and-a-gap.
      assert Enum.map(token_rows(expanded(view)), &length/1) == [3, 3, 3]
    end

    test "emptying the tokens leaves a message, not a blank box" do
      view =
        Enum.reduce(0..9, mount_screen(ComponentScreen, %{slug: :pill}), fn i, acc ->
          render_info(acc, {:tap, {:token_drop, :"item_#{i}"}})
        end)

      assert assigns(view).pill_tokens == []
      assert_renderable(expanded(view))
      assert text(expanded(view)) =~ "No tags left"
    end

    test "reset brings every token back" do
      view =
        ComponentScreen
        |> mount_screen(%{slug: :pill})
        |> render_info({:tap, {:token_drop, :item_0}})
        |> render_info({:tap, :token_reset})

      assert length(assigns(view).pill_tokens) == 10
      assert text(expanded(view)) =~ "Item 0"
    end

    test "tapping a pill body sends its tag and the screen renders the pick" do
      view = mount_screen(ComponentScreen, %{slug: :pill})

      assert assigns(view).pill_picked == nil
      assert text(expanded(view)) =~ "Nothing picked yet"

      view = render_info(view, {:tap, {:pill_pick, :elixir}})

      assert assigns(view).pill_picked == :elixir
      assert text(expanded(view)) =~ "Picked: elixir"

      # Only the picked pill changes colour — a shared flag would light all three.
      # Scoped to the Tappable example's own pills: the Colour example ships a
      # deliberately :primary one, and the page chrome has more.
      lit =
        expanded(view)
        |> find_all(:box)
        |> Enum.filter(&(&1.props[:corner_radius] == :radius_pill))
        |> Enum.filter(&Enum.any?(~w(React Elixir Swift), fn l -> text(&1) =~ l end))
        |> Enum.filter(&(&1.props[:background] == :primary))

      assert [elixir] = lit
      assert text(elixir) =~ "Elixir"
    end

    test "the disabled pills wire no taps at all" do
      view = mount_screen(ComponentScreen, %{slug: :pill})

      disabled =
        expanded(view)
        |> find_all(:box)
        |> Enum.filter(&(&1.props[:corner_radius] == :radius_pill and text(&1) =~ "locked"))

      # on_tap AND on_remove are both passed in the example, and neither survives.
      assert [pill] = disabled
      refute Map.has_key?(pill.props, :on_tap)
      assert Enum.all?(find_all(pill, :row), &(not Map.has_key?(&1.props, :on_tap)))
    end

    test "the Mark and Highlight pages render every example and their props" do
      for {slug, headings} <- [
            {:mark, ["Highlighted text", "A colour per mark", "In a sentence", "Colours"]},
            {:highlight,
             [
               "Every occurrence",
               "Case sensitivity",
               "Matching a query",
               "Several queries",
               "Wrapping a sentence"
             ]}
          ] do
        view = mount_screen(ComponentScreen, %{slug: slug})

        assert_renderable(expanded(view))
        for heading <- headings ++ ["Props"], do: assert(text(view) =~ heading)
      end
    end

    test "no mark anywhere on either page fills its line" do
      # The bug the pages showed: a mark rendered as a full-width bar, because a
      # Box told neither width nor fill_width fills its parent. Every tinted Box
      # on both pages is checked, not just the component in isolation.
      for slug <- [:mark, :highlight] do
        marks =
          ComponentScreen
          |> mount_screen(%{slug: slug})
          |> expanded()
          |> find_all(:box)
          |> Enum.filter(&(&1.props[:background] == MishkaMark.default_fill()))

        refute Enum.empty?(marks), "no marks found on the #{slug} page"
        assert Enum.all?(marks, &(&1.props[:fill_width] == false))
      end
    end

    test "the Highlight page's case-sensitivity example really differs" do
      # Both halves show the same sentence and the same query; if case_sensitive
      # were dropped in the forwarding they would render identically and the
      # example would quietly claim something untrue.
      marks =
        ComponentScreen
        |> mount_screen(%{slug: :highlight})
        |> expanded()
        |> find_all(:box)
        |> Enum.filter(&(&1.props[:background] == MishkaMark.default_fill()))
        |> Enum.map(&text/1)

      assert "This" in marks
      assert "THIS" in marks
      # …and the sensitive half contributes only the lowercase one, so the
      # uppercase forms appear fewer times than the lowercase.
      assert Enum.count(marks, &(&1 == "this")) > Enum.count(marks, &(&1 == "THIS"))
    end

    test "the Highlight page's live query follows the tapped button" do
      view = mount_screen(ComponentScreen, %{slug: :highlight})

      assert assigns(view).hl_query == "che"
      view = render_info(view, {:tap, {:hl_query, "beam"}})
      assert assigns(view).hl_query == "beam"
    end

    test "unknown slug renders a not-found page (still renderable)" do
      view = mount_screen(ComponentScreen, %{slug: :ghost})

      assert assigns(view).entry == nil
      assert_renderable(expanded(view))
      assert text(view) =~ "Not found"
    end
  end
end
