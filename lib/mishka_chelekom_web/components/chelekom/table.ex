defmodule MishkaChelekom.Table do
  use Phoenix.Component
  import MishkaChelekomComponents

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :variant, :string, default: nil, doc: ""
  attr :rounded, :string, default: nil, doc: ""
  attr :padding, :string, default: "small", doc: ""
  attr :text_size, :string, default: "small", doc: ""
  attr :color, :string, default: nil, doc: ""
  attr :border, :string, default: nil, doc: ""
  attr :header_border, :string, default: nil, doc: ""
  attr :rows_border, :string, default: nil, doc: ""
  attr :cols_border, :string, default: nil, doc: ""
  attr :thead_class, :string, default: nil, doc: ""
  attr :footer_class, :string, default: nil, doc: ""
  attr :table_fixed, :boolean, default: false, doc: ""
  attr :text_position, :string, default: "left", doc: ""
  attr :rest, :global, doc: ""

  slot :inner_block, required: false, doc: ""

  slot :header do
    attr :class, :any
    attr :icon, :any
    attr :icon_class, :any
  end

  slot :footer do
    attr :class, :any
    attr :icon, :any
    attr :icon_class, :any
  end

  def table(assigns) do
    ~H"""
    <div class="-m-1.5 overflow-x-auto">
      <div class="p-1.5 min-w-full inline-block align-middle">
        <div class={[
          "overflow-hidden",
          color_variant(@variant, @color),
          text_position(@text_position),
          rounded_size(@rounded),
          text_size(@text_size),
          border_class(@border),
          padding_size(@padding),
          @header_border && header_border(@header_border),
          @rows_border && rows_border(@rows_border),
          @cols_border && cols_border(@cols_border)
        ]}>
          <table
            class={[
              "min-w-full",
              @table_fixed && "table-fixed",
              @class
            ]}
            {@rest}
          >
            <thead class={@thead_class}>
              <.tr>
                <.th
                  :for={{header, index} <- Enum.with_index(@header, 1)}
                  id={"#{@id}-table-header-#{index}"}
                  scope="col"
                  class={header[:class]}
                >
                  <.icon
                    :if={header[:icon]}
                    name={header[:icon]}
                    class={["table-header-icon block me-2", header[:icon_class]]}
                  />
                  <%= render_slot(header) %>
                </.th>
              </.tr>
            </thead>

            <tbody class="">
              <%= render_slot(@inner_block) %>
            </tbody>

            <tfoot :if={length(@footer) > 0} class={@footer_class}>
              <.tr>
                <.td
                  :for={{footer, index} <- Enum.with_index(@footer, 1)}
                  id={"#{@id}-table-footer-#{index}"}
                  class={footer[:class]}
                >
                  <div class="flex items-center">
                    <.icon
                      :if={footer[:icon]}
                      name={footer[:icon]}
                      class={["table-footer-icon block me-2", footer[:icon_class]]}
                    />
                    <%= render_slot(footer) %>
                  </div>
                </.td>
              </.tr>
            </tfoot>
          </table>
        </div>
      </div>
    </div>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :scope, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  def th(assigns) do
    ~H"""
    <th scoep={@scope} class={["table-header", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </th>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  def tr(assigns) do
    ~H"""
    <tr class={["table-row", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </tr>
    """
  end

  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""
  slot :inner_block, required: false, doc: ""

  def td(assigns) do
    ~H"""
    <td class={["table-data-cell", @class]} {@rest}>
      <%= render_slot(@inner_block) %>
    </td>
    """
  end

  defp rounded_size("none"), do: "rounded-none"
  defp rounded_size("extra_small"), do: "rounded-sm"
  defp rounded_size("small"), do: "rounded"
  defp rounded_size("medium"), do: "rounded-md"
  defp rounded_size("large"), do: "rounded-lg"
  defp rounded_size("extra_large"), do: "rounded-xl"
  defp rounded_size(params) when is_binary(params), do: [params]
  defp rounded_size(_), do: nil

  defp text_size("extra_small"), do: "text-xs"
  defp text_size("small"), do: "text-sm"
  defp text_size("medium"), do: "text-base"
  defp text_size("large"), do: "text-lg"
  defp text_size("extra_large"), do: "text-xl"
  defp text_size(params) when is_binary(params), do: [params]
  defp text_size(_), do: text_size("small")

  defp text_position("left"), do: "[&_table]:text-left [&_table_thead]:text-left"
  defp text_position("right"), do: "[&_table]:text-right [&_table_thead]:text-right"
  defp text_position("center"), do: "[&_table]:text-center [&_table_thead]:text-center"
  defp text_position("justify"), do: "[&_table]:text-justify [&_table_thead]:text-justify"
  defp text_position("start"), do: "[&_table]:text-start [&_table_thead]:text-start"
  defp text_position("end"), do: "[&_table]:text-end [&_table_thead]:text-end"
  defp text_position(_), do: text_position("left")

  defp border_class("extra_small"), do: "border"
  defp border_class("small"), do: "border-2"
  defp border_class("medium"), do: "border-[3px]"
  defp border_class("large"), do: "border-4"
  defp border_class("extra_large"), do: "border-[5px]"
  defp border_class(params) when is_binary(params), do: [params]
  defp border_class(_), do: nil

  defp cols_border("extra_small") do
    [
      "[&_table_thead_th:not(:last-child)]:border-e",
      "[&_table_tbody_td:not(:last-child)]:border-e",
      "[&_table_tfoot_td:not(:last-child)]:border-e"
    ]
  end

  defp cols_border("small") do
    [
      "[&_table_thead_th:not(:last-child)]:border-e-2",
      "[&_table_tbody_td:not(:last-child)]:border-e-2",
      "[&_table_tfoot_td:not(:last-child)]:border-e-2"
    ]
  end

  defp cols_border("medium") do
    [
      "[&_table_thead_th:not(:last-child)]:border-e-[3px]",
      "[&_table_tbody_td:not(:last-child)]:border-e-[3px]",
      "[&_table_tfoot_td:not(:last-child)]:border-e-[3px]"
    ]
  end

  defp cols_border("large") do
    [
      "[&_table_thead_th:not(:last-child)]:border-e-4",
      "[&_table_tbody_td:not(:last-child)]:border-e-4",
      "[&_table_tfoot_td:not(:last-child)]:border-e-4"
    ]
  end

  defp cols_border("extra_large") do
    [
      "[&_table_thead_th:not(:last-child)]:border-e-[5px]",
      "[&_table_tbody_td:not(:last-child)]:border-e-[5px]",
      "[&_table_tfoot_td:not(:last-child)]:border-e-[5px]"
    ]
  end

  defp cols_border(params) when is_binary(params), do: [params]
  defp cols_border(_), do: nil

  defp rows_border("extra_small"), do: "[&_table_tbody]:divide-y"
  defp rows_border("small"), do: "[&_table_tbody]:divide-y-2"
  defp rows_border("medium"), do: "[&_table_tbody]:divide-y-[3px]"
  defp rows_border("large"), do: "[&_table_tbody]:divide-y-4"
  defp rows_border("extra_large"), do: "[&_table_tbody]:divide-y-[5px]"
  defp rows_border(params) when is_binary(params), do: [params]
  defp rows_border(_), do: nil

  defp header_border("extra_small"), do: "[&_table]:divide-y"
  defp header_border("small"), do: "[&_table]:divide-y-2"
  defp header_border("medium"), do: "[&_table]:divide-y-[3px]"
  defp header_border("large"), do: "[&_table]:divide-y-4"
  defp header_border("extra_large"), do: "[&_table]:divide-y-[5px]"
  defp header_border(params) when is_binary(params), do: [params]
  defp header_border(_), do: nil

  defp padding_size("extra_small") do
    [
      "[&_table_.table-data-cell]:px-3 [&_table_.table-data-cell]:py-1.5",
      "[&_table_.table-header]:px-3 [&_table_.table-header]:py-1.5"
    ]
  end

  defp padding_size("small") do
    [
      "[&_table_.table-data-cell]:px-4 [&_table_.table-data-cell]:py-2",
      "[&_table_.table-header]:px-4 [&_table_.table-header]:py-2"
    ]
  end

  defp padding_size("medium") do
    [
      "[&_table_.table-data-cell]:px-5 [&_table_.table-data-cell]:py-2.5",
      "[&_table_.table-header]:px-5 [&_table_.table-header]:py-2.5"
    ]
  end

  defp padding_size("large") do
    [
      "[&_table_.table-data-cell]:px-6 [&_table_.table-data-cell]:py-3",
      "[&_table_.table-header]:px-6 [&_table_.table-header]:py-3"
    ]
  end

  defp padding_size("extra_large") do
    [
      "[&_table_.table-data-cell]:px-7 [&_table_.table-data-cell]:py-3.5",
      "[&_table_.table-header]:px-7 [&_table_.table-header]:py-3.5"
    ]
  end

  defp padding_size(params) when is_binary(params), do: params
  defp padding_size(_), do: padding_size("small")

  defp color_variant("default", "white") do
    "[&_table]:bg-white text-[#3E3E3E] border-white [&_*]:divide-white [&_td]:border-white [&_th]:border-white"
  end

  defp color_variant("default", "primary") do
    "[&_table]:bg-[#4363EC] text-white border-[#2441de] [&_*]:divide-[#2441de] [&_td]:border-[#2441de] [&_th]:border-[#2441de]"
  end

  defp color_variant("default", "secondary") do
    "[&_table]:bg-[#6B6E7C] text-white border-[#877C7C] [&_*]:divide-[#877C7C] [&_td]:border-[#877C7C] [&_th]:border-[#877C7C]"
  end

  defp color_variant("default", "success") do
    "[&_table]:bg-[#ECFEF3] text-[#047857] border-[#6EE7B7] [&_*]:divide-[#6EE7B7] [&_td]:border-[#6EE7B7] [&_th]:border-[#6EE7B7]"
  end

  defp color_variant("default", "warning") do
    "[&_table]:bg-[#FFF8E6] text-[#FF8B08] border-[#FF8B08] [&_*]:divide-[#FF8B08] [&_td]:border-[#FF8B08] [&_th]:border-[#FF8B08]"
  end

  defp color_variant("default", "danger") do
    "[&_table]:bg-[#FFE6E6] text-[#E73B3B] border-[#E73B3B] [&_*]:divide-[#E73B3B] [&_td]:border-[#E73B3B] [&_th]:border-[#E73B3B]"
  end

  defp color_variant("default", "info") do
    "[&_table]:bg-[#E5F0FF] text-[#004FC4] border-[#004FC4] [&_*]:divide-[#004FC4] [&_td]:border-[#004FC4] [&_th]:border-[#004FC4]"
  end

  defp color_variant("default", "misc") do
    "[&_table]:bg-[#FFE6FF] text-[#52059C] border-[#52059C] [&_*]:divide-[#52059C] [&_td]:border-[#52059C] [&_th]:border-[#52059C]"
  end

  defp color_variant("default", "dawn") do
    "[&_table]:bg-[#FFECDA] text-[#4D4137] border-[#4D4137] [&_*]:divide-[#4D4137] [&_td]:border-[#4D4137] [&_th]:border-[#4D4137]"
  end

  defp color_variant("default", "light") do
    "[&_table]:bg-[#E3E7F1] text-[#707483] border-[#707483] [&_*]:divide-[#707483] [&_td]:border-[#707483] [&_th]:border-[#707483]"
  end

  defp color_variant("default", "dark") do
    "[&_table]:bg-[#1E1E1E] text-white border-[#050404] [&_*]:divide-[#DADADA] [&_td]:border-[#050404] [&_th]:border-[#050404]"
  end

  defp color_variant("outline", "white") do
    "text-white border-white [&_*]:divide-white [&_td]:border-white [&_th]:border-white"
  end

  defp color_variant("outline", "primary") do
    "text-[#4363EC] border-[#4363EC] [&_*]:divide-[#4363EC] [&_td]:border-[#4363EC] [&_th]:border-[#4363EC]"
  end

  defp color_variant("outline", "secondary") do
    "text-[#6B6E7C] border-[#6B6E7C] [&_*]:divide-[#6B6E7C] [&_td]:border-[#6B6E7C] [&_th]:border-[#6B6E7C]"
  end

  defp color_variant("outline", "success") do
    "text-[#227A52] border-[#6EE7B7] [&_*]:divide-[#6EE7B7] [&_td]:border-[#6EE7B7] [&_th]:border-[#6EE7B7]"
  end

  defp color_variant("outline", "warning") do
    "text-[#FF8B08] border-[#FF8B08] [&_*]:divide-[#FF8B08] [&_td]:border-[#FF8B08] [&_th]:border-[#FF8B08]"
  end

  defp color_variant("outline", "danger") do
    "text-[#E73B3B] border-[#E73B3B] [&_*]:divide-[#E73B3B] [&_td]:border-[#E73B3B] [&_th]:border-[#E73B3B]"
  end

  defp color_variant("outline", "info") do
    "text-[#004FC4] border-[#004FC4] [&_*]:divide-[#004FC4] [&_td]:border-[#004FC4] [&_th]:border-[#004FC4]"
  end

  defp color_variant("outline", "misc") do
    "text-[#52059C] border-[#52059C] [&_*]:divide-[#52059C] [&_td]:border-[#52059C] [&_th]:border-[#52059C]"
  end

  defp color_variant("outline", "dawn") do
    "text-[#4D4137] border-[#4D4137] [&_*]:divide-[#4D4137] [&_td]:border-[#4D4137] [&_th]:border-[#4D4137]"
  end

  defp color_variant("outline", "light") do
    "text-[#707483] border-[#707483] [&_*]:divide-[#707483] [&_td]:border-[#707483] [&_th]:border-[#707483]"
  end

  defp color_variant("outline", "dark") do
    "text-[#1E1E1E] border-[#050404] [&_*]:divide-[#050404] [&_td]:border-[#050404] [&_th]:border-[#050404]"
  end

  defp color_variant("unbordered", "white") do
    "[&_table]:bg-white border-transparent text-[#3E3E3E] [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("unbordered", "primary") do
    "[&_table]:bg-[#4363EC] border-transparent text-white [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("unbordered", "secondary") do
    "[&_table]:bg-[#6B6E7C] border-transparent text-white [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("unbordered", "success") do
    "[&_table]:bg-[#ECFEF3] border-transparent text-[#047857] [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("unbordered", "warning") do
    "[&_table]:bg-[#FFF8E6] border-transparent text-[#FF8B08] [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("unbordered", "danger") do
    "[&_table]:bg-[#FFE6E6] border-transparent text-[#E73B3B] [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("unbordered", "info") do
    "[&_table]:bg-[#E5F0FF] border-transparent text-[#004FC4] [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("unbordered", "misc") do
    "[&_table]:bg-[#FFE6FF] border-transparent text-[#52059C] [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("unbordered", "dawn") do
    "[&_table]:bg-[#FFECDA] border-transparent text-[#4D4137] [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("unbordered", "light") do
    "[&_table]:bg-[#E3E7F1] border-transparent text-[#707483] [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("unbordered", "dark") do
    "[&_table]:bg-[#1E1E1E] border-transparent text-white [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("shadow", "white") do
    "[&_table]:bg-white border-[#DADADA] text-[#3E3E3E] [&_*]:divide-[#DADADA] [&_td]:border-[#DADADA] [&_th]:border-[#DADADA] shadow"
  end

  defp color_variant("shadow", "primary") do
    "[&_table]:bg-[#4363EC] border-[#2441de] text-white [&_*]:divide-[#2441de] [&_td]:border-[#2441de] [&_th]:border-[#2441de] shadow"
  end

  defp color_variant("shadow", "secondary") do
    "[&_table]:bg-[#6B6E7C] border-[#877C7C] text-white [&_*]:divide-[#877C7C] [&_td]:border-[#877C7C] [&_th]:border-[#877C7C] shadow"
  end

  defp color_variant("shadow", "success") do
    "[&_table]:bg-[#ECFEF3] border-[#6EE7B7] text-[#227A52] [&_*]:divide-[#6EE7B7] [&_td]:border-[#6EE7B7] [&_th]:border-[#6EE7B7] shadow"
  end

  defp color_variant("shadow", "warning") do
    "[&_table]:bg-[#FFF8E6] border-[#FF8B08] text-[#FF8B08] [&_*]:divide-[#FF8B08] [&_td]:border-[#FF8B08] [&_th]:border-[#FF8B08] shadow"
  end

  defp color_variant("shadow", "danger") do
    "[&_table]:bg-[#FFE6E6] border-[#E73B3B] text-[#E73B3B] [&_*]:divide-[#E73B3B] [&_td]:border-[#E73B3B] [&_th]:border-[#E73B3B] shadow"
  end

  defp color_variant("shadow", "info") do
    "[&_table]:bg-[#E5F0FF] border-[#004FC4] text-[#004FC4] [&_*]:divide-[#004FC4] [&_td]:border-[#004FC4] [&_th]:border-[#004FC4] shadow"
  end

  defp color_variant("shadow", "misc") do
    "[&_table]:bg-[#FFE6FF] border-[#52059C] text-[#52059C] [&_*]:divide-[#52059C] [&_td]:border-[#52059C] [&_th]:border-[#52059C] shadow"
  end

  defp color_variant("shadow", "dawn") do
    "[&_table]:bg-[#FFECDA] border-[#4D4137] text-[#4D4137] [&_*]:divide-[#4D4137] [&_td]:border-[#4D4137] [&_th]:border-[#4D4137] shadow"
  end

  defp color_variant("shadow", "light") do
    "[&_table]:bg-[#E3E7F1] border-[#707483] text-[#707483] [&_*]:divide-[#707483] [&_td]:border-[#707483] [&_th]:border-[#707074837483] shadow"
  end

  defp color_variant("shadow", "dark") do
    "[&_table]:bg-[#1E1E1E] border-[#050404] text-white [&_*]:divide-[#050404] [&_td]:border-[#050404] [&_th]:border-[#050404] shadow"
  end

  defp color_variant("transparent", "white") do
    "text-white border-transparent [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("transparent", "primary") do
    "text-[#4363EC] border-transparent [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("transparent", "secondary") do
    "text-[#6B6E7C] border-transparent [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("transparent", "success") do
    "text-[#227A52] border-transparent [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("transparent", "warning") do
    "text-[#FF8B08] border-transparent [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("transparent", "danger") do
    "text-[#E73B3B] border-transparent [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("transparent", "info") do
    "text-[#6663FD] border-transparent [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("transparent", "misc") do
    "text-[#52059C] border-transparent [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("transparent", "dawn") do
    "text-[#4D4137] border-transparent [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("transparent", "light") do
    "text-[#707483] border-transparent [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("transparent", "dark") do
    "text-[#1E1E1E] border-transparent [&_*]:divide-transparent [&_td]:border-transparent [&_th]:border-transparent"
  end

  defp color_variant("hoverable", "white") do
    [
      "[&_table]:bg-white hover:[&_table_tbody_tr]:bg-[#DADADA] text-[#3E3E3E]",
      "border-white [&_*]:divide-white [&_td]:border-white [&_th]:border-white"
    ]
  end

  defp color_variant("hoverable", "silver") do
    [
      "[&_table]:bg-white hover:[&_table_tbody_tr]:bg-[#e3e3e3] text-[#3E3E3E]",
      "border-[#B5b7bb] [&_*]:divide-[#B5b7bb] [&_td]:border-[#B5b7bb] [&_th]:border-[#B5b7bb]"
    ]
  end

  defp color_variant("hoverable", "primary") do
    [
      "[&_table]:bg-white text-[#4363EC] hover:[&_table_tbody_tr]:bg-[#4363EC] hover:[&_table_tbody_tr]:text-white",
      "border-[#2441de] [&_*]:divide-[#2441de] [&_td]:border-[#2441de] [&_th]:border-[#2441de]"
    ]
  end

  defp color_variant("hoverable", "secondary") do
    [
      "[&_table]:bg-white hover:[&_table_tbody_tr]:bg-[#6B6E7C] hover:[&_table_tbody_tr]:text-white border-[#877C7C]",
      "[&_*]:divide-[#877C7C] [&_td]:border-[#877C7C] [&_th]:border-[#877C7C]"
    ]
  end

  defp color_variant("hoverable", "success") do
    [
      "[&_table]:bg-white hover:[&_table_tbody_tr]:bg-[#ECFEF3] text-[#047857]",
      "border-[#6EE7B7] [&_*]:divide-[#6EE7B7] [&_td]:border-[#6EE7B7] [&_th]:border-[#6EE7B7]"
    ]
  end

  defp color_variant("hoverable", "warning") do
    [
      "[&_table]:bg-white hover:[&_table_tbody_tr]:bg-[#FFF8E6] text-[#FF8B08]",
      "border-[#FF8B08] [&_*]:divide-[#FF8B08] [&_td]:border-[#FF8B08] [&_th]:border-[#FF8B08]"
    ]
  end

  defp color_variant("hoverable", "danger") do
    [
      "[&_table]:bg-white hover:[&_table_tbody_tr]:bg-[#FFE6E6] text-[#E73B3B]",
      "border-[#E73B3B] [&_*]:divide-[#E73B3B] [&_td]:border-[#E73B3B] [&_th]:border-[#E73B3B]"
    ]
  end

  defp color_variant("hoverable", "info") do
    [
      "[&_table]:bg-white hover:[&_table_tbody_tr]:bg-[#E5F0FF] text-[#004FC4]",
      "border-[#004FC4] [&_*]:divide-[#004FC4] [&_td]:border-[#004FC4] [&_th]:border-[#004FC4]"
    ]
  end

  defp color_variant("hoverable", "misc") do
    [
      "[&_table]:bg-white hover:[&_table_tbody_tr]:bg-[#FFE6FF] text-[#52059C]",
      "border-[#52059C] [&_*]:divide-[#52059C] [&_td]:border-[#52059C] [&_th]:border-[#52059C]"
    ]
  end

  defp color_variant("hoverable", "dawn") do
    [
      "[&_table]:bg-white hover:[&_table_tbody_tr]:bg-[#FFECDA] text-[#4D4137]",
      "border-[#4D4137] [&_*]:divide-[#4D4137] [&_td]:border-[#4D4137] [&_th]:border-[#4D4137]"
    ]
  end

  defp color_variant("hoverable", "light") do
    [
      "[&_table]:bg-white hover:[&_table_tbody_tr]:bg-[#E3E7F1] text-[#707483]",
      "border-[#707483] [&_*]:divide-[#707483] [&_td]:border-[#707483] [&_th]:border-[#707483]"
    ]
  end

  defp color_variant("hoverable", "dark") do
    [
      "[&_table]:bg-white text-[#1E1E1E] hover:[&_table_tbody_tr]:bg-[#1E1E1E] hover:[&_table_tbody_tr]:text-white",
      "border-[#050404] [&_*]:divide-[#DADADA] [&_td]:border-[#050404] [&_th]:border-[#050404]"
    ]
  end

  defp color_variant("stripped", "white") do
    [
      "[&_table]:bg-white odd:[&_table_tbody_tr]:bg-[#f7f7f7] text-[#3E3E3E] border-white",
      "[&_*]:divide-white [&_td]:border-white [&_th]:border-white"
    ]
  end

  defp color_variant("stripped", "primary") do
    [
      "[&_table]:bg-[#4363EC] odd:[&_table_tbody_tr]:bg-[#5874ed] text-white border-[#2441de]",
      "[&_*]:divide-[#2441de] [&_td]:border-[#2441de] [&_th]:border-[#2441de]"
    ]
  end

  defp color_variant("stripped", "secondary") do
    [
      "[&_table]:bg-[#6B6E7C] odd:[&_table_tbody_tr]:bg-[#8a8d9e] text-white border-[#877C7C]",
      "[&_*]:divide-[#877C7C] [&_td]:border-[#877C7C] [&_th]:border-[#877C7C]"
    ]
  end

  defp color_variant("stripped", "success") do
    [
      "[&_table]:bg-[#ECFEF3] odd:[&_table_tbody_tr]:bg-[#cffae0] text-[#047857] border-[#6EE7B7]",
      "[&_*]:divide-[#6EE7B7] [&_td]:border-[#6EE7B7] [&_th]:border-[#6EE7B7]"
    ]
  end

  defp color_variant("stripped", "warning") do
    [
      "[&_table]:bg-[#FFF8E6] odd:[&_table_tbody_tr]:bg-[#faedcd] text-[#FF8B08] border-[#FF8B08]",
      "[&_*]:divide-[#FF8B08] [&_td]:border-[#FF8B08] [&_th]:border-[#FF8B08]"
    ]
  end

  defp color_variant("stripped", "danger") do
    [
      "[&_table]:bg-[#FFE6E6] odd:[&_table_tbody_tr]:bg-[#fcd4d4] text-[#E73B3B] border-[#E73B3B]",
      "[&_*]:divide-[#E73B3B] [&_td]:border-[#E73B3B] [&_th]:border-[#E73B3B]"
    ]
  end

  defp color_variant("stripped", "info") do
    [
      "[&_table]:bg-[#E5F0FF] odd:[&_table_tbody_tr]:bg-[#d2e4fc] text-[#004FC4] border-[#004FC4]",
      "[&_*]:divide-[#004FC4] [&_td]:border-[#004FC4] [&_th]:border-[#004FC4]"
    ]
  end

  defp color_variant("stripped", "misc") do
    [
      "[&_table]:bg-[#FFE6FF] odd:[&_table_tbody_tr]:bg-[#ffdbff] text-[#52059C] border-[#52059C]",
      "[&_*]:divide-[#52059C] [&_td]:border-[#52059C] [&_th]:border-[#52059C]"
    ]
  end

  defp color_variant("stripped", "dawn") do
    [
      "[&_table]:bg-[#FFECDA] odd:[&_table_tbody_tr]:bg-[#ffe0c2] text-[#4D4137] border-[#4D4137]",
      "[&_*]:divide-[#4D4137] [&_td]:border-[#4D4137] [&_th]:border-[#4D4137]"
    ]
  end

  defp color_variant("stripped", "light") do
    [
      "[&_table]:bg-[#E3E7F1] odd:[&_table_tbody_tr]:bg-[#d1d9ed] text-[#707483] border-[#707483]",
      "[&_*]:divide-[#707483] [&_td]:border-[#707483] [&_th]:border-[#707483]"
    ]
  end

  defp color_variant("stripped", "dark") do
    [
      "[&_table]:bg-[#1E1E1E] odd:[&_table_tbody_tr]:bg-[#333333] text-white border-[#050404]",
      "[&_*]:divide-[#DADADA] [&_td]:border-[#050404] [&_th]:border-[#050404]"
    ]
  end

  defp color_variant(_, _), do: nil
end
