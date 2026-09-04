defmodule DevelopmentWeb.Components.Headless.Table do
  @moduledoc """
  Headless **table** — rows and columns with the parts that are easy to get wrong.

  daisyUI's table is a stylesheet: `table`, `table-zebra`, `table-pin-rows`. What it cannot give
  you is the semantics, and that is what this owns. A `<caption>` names the table (visually hidden
  by default, because a name is for the screen reader that lands on it, not necessarily for the
  page). Header cells carry `scope="col"`, and the row header — the column you mark `row_header` —
  carries `scope="row"`, which is what lets a screen reader say "Cy Ganderton, Quality Control"
  instead of reading a bare cell.

  Sorting is a `<button>` inside the header cell and `aria-sort` on the cell itself, so the current
  order is announced rather than merely drawn as an arrow. Only one column can be sorted, so only
  one cell ever carries it.

  Selection is a checkbox column with a real header checkbox that reflects three states — none,
  some, all — because a select-all that looks unchecked while half the page is selected is a lie.
  The middle state has no HTML attribute; it exists only as a DOM property, which is what the tiny
  shared `Indeterminate` hook is for.

  Rows are keyed by `row_id`, so LiveView patches the row that changed instead of re-rendering the
  table.

  Parts: `caption`, `head`, `header`, `sort`, `body`, `row`, `cell`, `select`, `select-all`,
  `empty`, `foot`.

  Ships **no** colors, sizing or spacing — style via `chelekom-table*`.

  **Documentation:** https://mishka.tools/chelekom/docs/headless/table
  """
  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc type: :component
  attr :id, :string, required: true, doc: "Unique id"
  attr :rows, :list, required: true, doc: "The rows to render"
  attr :caption, :string, default: nil, doc: "Names the table for assistive tech"

  attr :show_caption, :boolean,
    default: false,
    doc: "Also show the caption; it is there for screen readers either way"

  attr :row_id, :any,
    default: nil,
    doc: "A function of the row returning its DOM id, so LiveView can patch one row"

  attr :row_click, :any, default: nil, doc: "A function of the row returning a JS command"

  attr :sort_by, :string, default: nil, doc: "Which column is sorted"

  attr :sort_dir, :string,
    default: "asc",
    values: ~w(asc desc),
    doc: "Which way the sorted column runs"

  attr :on_sort, :string,
    default: nil,
    doc: "LiveView event pushed as `%{key, dir}` when a sortable header is activated"

  attr :selected, :list, default: [], doc: "Ids of the selected rows"
  attr :on_select, :string, default: nil, doc: "Event pushed as `%{id, selected}` per row"
  attr :on_select_all, :string, default: nil, doc: "Event pushed as `%{selected}` for the header"
  attr :select_label, :string, default: "Select row", doc: "Accessible name for a row's checkbox"
  attr :select_all_label, :string, default: "Select all rows", doc: "…and for the header's"

  attr :class, :any, default: nil, doc: "Extra classes for the root"
  attr :row_class, :any, default: nil, doc: ~s|Extra classes for `data-part="row"`|
  attr :cell_class, :any, default: nil, doc: ~s|Extra classes for `data-part="cell"`|
  attr :body_class, :any, default: nil, doc: ~s|Extra classes for `data-part="body"`|
  attr :caption_class, :any, default: nil, doc: ~s|Extra classes for `data-part="caption"`|
  attr :empty_class, :any, default: nil, doc: ~s|Extra classes for `data-part="empty"`|
  attr :foot_class, :any, default: nil, doc: ~s|Extra classes for `data-part="foot"`|
  attr :head_class, :any, default: nil, doc: ~s|Extra classes for `data-part="head"`|
  attr :header_class, :any, default: nil, doc: ~s|Extra classes for `data-part="header"`|

  attr :select_class, :any,
    default: nil,
    doc: ~s|Extra classes for the `data-part="select-all"` and `data-part="select"` checkboxes|

  attr :sort_class, :any, default: nil, doc: ~s|Extra classes for `data-part="sort"`|
  attr :rest, :global

  slot :col, required: true, doc: "One column" do
    attr :label, :string, doc: "Header text"
    attr :key, :string, doc: "Sort key; a column without one is not sortable"
    attr :row_header, :boolean, doc: "Render this column's cells as `<th scope=\"row\">`"
    attr :align, :string, doc: "start | center | end, reflected as data-align"
    attr :class, :any
  end

  slot :empty, doc: "Shown instead of the body when there are no rows"
  slot :foot, doc: "A `<tfoot>` row; receives no rows, so totals are the caller's to compute"

  def table(assigns) do
    assigns = assign(assigns, :selectable?, assigns.on_select != nil)

    ~H"""
    <table
      id={@id}
      data-part="root"
      data-sort-by={@sort_by}
      data-sort-dir={@sort_by && @sort_dir}
      class={["chelekom-table", @class]}
      {@rest}
    >
      <caption
        :if={@caption}
        data-part="caption"
        data-hidden={!@show_caption}
        class={["chelekom-table__caption", @caption_class]}
      >
        {@caption}
      </caption>

      <thead data-part="head" class={["chelekom-table__head", @head_class]}>
        <tr data-part="row" class={["chelekom-table__row", @row_class]}>
          <th
            :if={@selectable?}
            scope="col"
            data-part="header"
            class={["chelekom-table__header", @header_class]}
          >
            <input
              type="checkbox"
              id={"#{@id}-select-all"}
              phx-hook="Indeterminate"
              data-part="select-all"
              data-indeterminate={some_selected?(@rows, @selected, @row_id)}
              checked={all_selected?(@rows, @selected, @row_id)}
              aria-label={@select_all_label}
              phx-click={@on_select_all && JS.push(@on_select_all)}
              class={["chelekom-table__select", @select_class]}
            />
          </th>

          <th
            :for={col <- @col}
            scope="col"
            data-part="header"
            data-align={col[:align]}
            data-sortable={sortable?(col, @on_sort)}
            aria-sort={aria_sort(col, @sort_by, @sort_dir)}
            class={["chelekom-table__header", @header_class, col[:class]]}
          >
            <button
              :if={sortable?(col, @on_sort)}
              type="button"
              data-part="sort"
              data-dir={col[:key] == @sort_by && @sort_dir}
              phx-click={
                JS.push(@on_sort, value: %{key: col[:key], dir: next_dir(col, @sort_by, @sort_dir)})
              }
              class={["chelekom-table__sort", @sort_class]}
            >{col[:label]}</button>

            <span :if={!sortable?(col, @on_sort)}>{col[:label]}</span>
          </th>
        </tr>
      </thead>

      <tbody
        :if={@rows != []}
        data-part="body"
        id={"#{@id}-body"}
        class={["chelekom-table__body", @body_class]}
      >
        <tr
          :for={row <- @rows}
          id={@row_id && @row_id.(row)}
          data-part="row"
          data-selected={selected?(row, @selected, @row_id)}
          phx-click={@row_click && @row_click.(row)}
          class={["chelekom-table__row", @row_class]}
        >
          <td :if={@selectable?} data-part="cell" class={["chelekom-table__cell", @cell_class]}>
            <input
              type="checkbox"
              data-part="select"
              checked={selected?(row, @selected, @row_id)}
              aria-label={@select_label}
              phx-click={JS.push(@on_select, value: %{id: @row_id && @row_id.(row)})}
              class={["chelekom-table__select", @select_class]}
            />
          </td>

          <.dynamic_tag
            :for={col <- @col}
            tag_name={if col[:row_header], do: "th", else: "td"}
            data-part="cell"
            data-align={col[:align]}
            class={["chelekom-table__cell", @cell_class, col[:class]]}
            {cell_attrs(col)}
          >
            {render_slot(col, row)}
          </.dynamic_tag>
        </tr>
      </tbody>

      <tbody
        :if={@rows == [] && @empty != []}
        data-part="body"
        class={["chelekom-table__body", @body_class]}
      >
        <tr data-part="row" class={["chelekom-table__row", @row_class]}>
          <td
            data-part="empty"
            colspan={length(@col) + if(@selectable?, do: 1, else: 0)}
            class={["chelekom-table__empty", @empty_class]}
          >
            {render_slot(@empty)}
          </td>
        </tr>
      </tbody>

      <tfoot :if={@foot != []} data-part="foot" class={["chelekom-table__foot", @foot_class]}>
        <tr data-part="row" class={["chelekom-table__row", @row_class]}>{render_slot(@foot)}</tr>
      </tfoot>
    </table>
    """
  end

  # A column with no key cannot be sorted however willing the caller is — and neither can any of
  # them without somewhere to send the event.
  defp sortable?(col, on_sort), do: !!(col[:key] && on_sort)

  # Only the sorted column gets `aria-sort`; putting "none" on the rest is legal but makes a screen
  # reader announce sortability on every header it passes.
  defp aria_sort(col, sort_by, sort_dir) do
    if col[:key] && col[:key] == sort_by do
      if sort_dir == "desc", do: "descending", else: "ascending"
    end
  end

  # Clicking the sorted column reverses it; clicking any other starts it ascending, which is what
  # people expect from every table they have ever used.
  defp next_dir(col, sort_by, sort_dir) do
    if col[:key] == sort_by and sort_dir == "asc", do: "desc", else: "asc"
  end

  # `dynamic_tag` only takes tag-specific attributes through a spread, and `scope` is the attribute
  # that turns a cell into the row's name.
  defp cell_attrs(col), do: if(col[:row_header], do: %{"scope" => "row"}, else: %{})

  defp selected?(row, selected, row_id) do
    row_id != nil and row_id.(row) in selected
  end

  defp all_selected?([], _selected, _row_id), do: false

  defp all_selected?(rows, selected, row_id) do
    row_id != nil and Enum.all?(rows, &(row_id.(&1) in selected))
  end

  # "Some" is the state a plain checkbox cannot show: without it a half-selected page reads as
  # unselected, which is simply wrong.
  defp some_selected?(rows, selected, row_id) do
    row_id != nil and
      Enum.any?(rows, &(row_id.(&1) in selected)) and
      not Enum.all?(rows, &(row_id.(&1) in selected))
  end
end
