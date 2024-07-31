defmodule PaginationTest do
  def get_pagination_range(total_pages, current_page, siblings \\ 1) do
    total_numbers = siblings * 2 + 3
    total_blocks = total_numbers + 2

    if total_pages > total_blocks do
      start_page = max(2, current_page - siblings)
      end_page = min(total_pages - 1, current_page + siblings)
      middle_range = range(start_page, end_page)

      has_left_spill = start_page > 2
      has_right_spill = total_pages - end_page > 1
      spill_offset = total_numbers - length(middle_range) - 1

      middle_range =
        cond do
          has_left_spill && !has_right_spill ->
            extra_pages = range(start_page - spill_offset, start_page - 1)
            extra_pages ++ middle_range

          !has_left_spill && has_right_spill ->
            extra_pages = range(end_page + 1, end_page + spill_offset)
            middle_range ++ extra_pages

          has_left_spill && has_right_spill ->
            middle_range

          true ->
            middle_range
        end

      %{
        start_items: [1],
        end_items: [total_pages],
        middle_range: middle_range
      }
    else
      %{
        start_items: range(1, total_pages),
        end_items: [],
        middle_range: []
      }
    end
  end

  defp range(from, to) when from > to, do: []

  defp range(from, to), do: Enum.to_list(from..to)
end
