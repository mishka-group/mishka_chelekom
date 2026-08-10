defmodule DevelopmentWeb.Components.Headless.Pagination do
  @moduledoc """
  Headless **pagination** — the page window, computed (Mantine `usePagination` parity).

  daisyUI's pagination is a row of buttons you write out by hand; the arithmetic is the part worth
  owning. Give it `total` and `page` and it works out which numbers to show: `boundaries` pages
  pinned at each end, `siblings` either side of the current one, and an ellipsis standing in for
  whatever is left. The window never changes width as you page through, which is what stops the
  control jumping under the cursor.

  Three ways to render a page. `on_select` makes each one a `<button>` that pushes `{page}`.
  `href` takes a function of the page number, so the pages are real links — crawlable, and they
  work with JavaScript off. `name` renders radio inputs instead, for a pagination that posts with a
  surrounding form and needs no JS at all. Pick one; they are mutually exclusive.

  The current page is a `<button aria-current="page" disabled>` rather than a link to where you
  already are. Previous/next disable themselves at the ends instead of wrapping — a control that
  silently jumps from the last page to the first is a bug, not a feature.

  Parts: `list`, `item`, `page`, `ellipsis`, `first`, `previous`, `next`, `last`.

  Ships **no** colors, sizing or spacing — style via `chelekom-pagination*`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/pagination
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc type: :component
  attr :id, :string, default: nil, doc: "Unique id"
  attr :label, :string, default: "Pagination", doc: "Accessible name for the nav landmark"
  attr :total, :integer, required: true, doc: "How many pages there are"
  attr :page, :integer, default: 1, doc: "The current page, 1-based"

  attr :siblings, :integer,
    default: 1,
    doc: "How many pages to show either side of the current one"

  attr :boundaries, :integer, default: 1, doc: "How many pages to pin at each end"

  attr :on_select, :any,
    default: nil,
    doc: "A JS command or LiveView event name; the event receives `%{page: n}`"

  attr :href, :any,
    default: nil,
    doc: "A function of the page number returning a path; renders real links instead of buttons"

  attr :name, :string,
    default: nil,
    doc: "Renders radio inputs under this name, for a pagination that posts with a form"

  attr :show_controls, :boolean, default: true, doc: "Render the previous/next controls"
  attr :show_edges, :boolean, default: false, doc: "Also render first/last controls"
  attr :disabled, :boolean, default: false, doc: "Disable every control"
  attr :previous_label, :string, default: "«", doc: "Content of the previous control"
  attr :next_label, :string, default: "»", doc: "Content of the next control"
  attr :first_label, :string, default: "«« ", doc: "Content of the first control"
  attr :last_label, :string, default: " »»", doc: "Content of the last control"
  attr :ellipsis_label, :string, default: "…", doc: "Content of the ellipsis"
  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :list_class, :any, default: nil, doc: ~s|Extra classes for `data-part="list"`|
  attr :control_class, :any, default: nil, doc: "Extra classes for every control"
  attr :rest, :global

  def pagination(assigns) do
    assigns =
      assigns
      |> assign(:page, clamp(assigns.page, assigns.total))
      |> assign(
        :window,
        window(assigns.total, assigns.page, assigns.siblings, assigns.boundaries)
      )

    ~H"""
    <nav
      id={@id}
      aria-label={@label}
      data-part="root"
      data-total={@total}
      data-page={@page}
      class={["chelekom-pagination", @class]}
      {@rest}
    >
      <ul data-part="list" class={["chelekom-pagination__list", @list_class]}>
        <.control
          :if={@show_edges}
          part="first"
          page={1}
          disabled={@disabled || @page == 1}
          label="First page"
          on_select={@on_select}
          href={@href}
          class={@control_class}
        >
          {@first_label}
        </.control>

        <.control
          :if={@show_controls}
          part="previous"
          page={@page - 1}
          disabled={@disabled || @page == 1}
          label="Previous page"
          on_select={@on_select}
          href={@href}
          class={@control_class}
        >
          {@previous_label}
        </.control>

        <li
          :for={{entry, index} <- Enum.with_index(@window)}
          data-part="item"
          class="chelekom-pagination__item"
        >
          <span
            :if={entry == :ellipsis}
            data-part="ellipsis"
            aria-hidden="true"
            class={["chelekom-pagination__ellipsis", @control_class]}
          >{@ellipsis_label}</span>

          <.page_control
            :if={entry != :ellipsis}
            page={entry}
            current?={entry == @page}
            disabled={@disabled}
            index={index}
            name={@name}
            on_select={@on_select}
            href={@href}
            class={@control_class}
          />
        </li>

        <.control
          :if={@show_controls}
          part="next"
          page={@page + 1}
          disabled={@disabled || @page == @total}
          label="Next page"
          on_select={@on_select}
          href={@href}
          class={@control_class}
        >
          {@next_label}
        </.control>

        <.control
          :if={@show_edges}
          part="last"
          page={@total}
          disabled={@disabled || @page == @total}
          label="Last page"
          on_select={@on_select}
          href={@href}
          class={@control_class}
        >
          {@last_label}
        </.control>
      </ul>
    </nav>
    """
  end

  attr :part, :string, required: true
  attr :page, :integer, required: true
  attr :disabled, :boolean, required: true
  attr :label, :string, required: true
  attr :on_select, :any, default: nil
  attr :href, :any, default: nil
  attr :class, :any, default: nil
  slot :inner_block, required: true

  # An edge control at the end of its travel is disabled, not hidden: a row of controls that
  # changes width as you page through is harder to hit than one that greys out.
  defp control(assigns) do
    ~H"""
    <li data-part="item" class="chelekom-pagination__item">
      <.link
        :if={@href && !@disabled}
        href={@href.(@page)}
        data-part={@part}
        aria-label={@label}
        class={["chelekom-pagination__control", @class]}
      >{render_slot(@inner_block)}</.link>

      <button
        :if={!(@href && !@disabled)}
        type="button"
        data-part={@part}
        aria-label={@label}
        disabled={@disabled}
        phx-click={!@disabled && select(@on_select, @page)}
        class={["chelekom-pagination__control", @class]}
      >{render_slot(@inner_block)}</button>
    </li>
    """
  end

  attr :page, :integer, required: true
  attr :current?, :boolean, required: true
  attr :disabled, :boolean, required: true
  attr :index, :integer, required: true
  attr :name, :string, default: nil
  attr :on_select, :any, default: nil
  attr :href, :any, default: nil
  attr :class, :any, default: nil

  defp page_control(%{name: name} = assigns) when is_binary(name) do
    ~H"""
    <input
      type="radio"
      name={@name}
      value={@page}
      checked={@current?}
      disabled={@disabled}
      aria-label={"Page #{@page}"}
      aria-current={@current? && "page"}
      data-part="page"
      data-page={@page}
      data-current={@current?}
      class={["chelekom-pagination__control", @class]}
    />
    """
  end

  defp page_control(assigns) do
    ~H"""
    <.link
      :if={@href && !@current? && !@disabled}
      href={@href.(@page)}
      data-part="page"
      data-page={@page}
      aria-label={"Page #{@page}"}
      class={["chelekom-pagination__control", @class]}
    >{@page}</.link>

    <button
      :if={!(@href && !@current? && !@disabled)}
      type="button"
      data-part="page"
      data-page={@page}
      data-current={@current?}
      aria-label={"Page #{@page}"}
      aria-current={@current? && "page"}
      disabled={@disabled || @current?}
      phx-click={!@disabled && !@current? && select(@on_select, @page)}
      class={["chelekom-pagination__control", @class]}
    >{@page}</button>
    """
  end

  defp select(%JS{} = js, _page), do: js
  defp select(event, page) when is_binary(event), do: JS.push(event, value: %{page: page})
  defp select(nil, _page), do: nil

  defp clamp(page, total) when is_integer(page), do: page |> max(1) |> min(max(total, 1))

  @doc """
  The page numbers to show, with `:ellipsis` where a run was elided.

  Kept public because it is the component's actual logic: a caller building its own control — a
  "load more", a jump-to box — should not have to re-derive the same window.
  """
  @spec window(pos_integer(), pos_integer(), non_neg_integer(), non_neg_integer()) ::
          [pos_integer() | :ellipsis]
  def window(total, page, siblings, boundaries) do
    # The widest the control can get. Below it every page fits, so nothing is elided and the window
    # is just the whole range.
    widest = siblings * 2 + 3 + boundaries * 2

    if widest >= total do
      Enum.to_list(1..max(total, 1)//1)
    else
      elided(total, clamp(page, total), siblings, boundaries)
    end
  end

  defp elided(total, page, siblings, boundaries) do
    left = max(page - siblings, boundaries)
    right = min(page + siblings, total - boundaries)

    left_dots? = left > boundaries + 2
    right_dots? = right < total - (boundaries + 1)

    cond do
      not left_dots? and right_dots? ->
        Enum.to_list(1..(siblings * 2 + boundaries + 2)//1) ++
          [:ellipsis] ++ Enum.to_list((total - boundaries + 1)..total//1)

      left_dots? and not right_dots? ->
        # The same count as the leading run above, not Mantine's `boundaries + 1 + 2 * siblings`:
        # theirs shows one fewer control at the end, so the row narrows as you reach the last page
        # and the buttons shift under the cursor.
        tail = siblings * 2 + boundaries + 2

        Enum.to_list(1..boundaries//1) ++
          [:ellipsis] ++ Enum.to_list((total - tail + 1)..total//1)

      true ->
        Enum.to_list(1..boundaries//1) ++
          [:ellipsis] ++
          Enum.to_list(left..right//1) ++
          [:ellipsis] ++ Enum.to_list((total - boundaries + 1)..total//1)
    end
  end
end
