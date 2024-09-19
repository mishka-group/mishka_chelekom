defmodule MishkaChelekom.Table do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def table(assigns) do
    ~H"""
    <div class="overflow-hidden">
      <table class="min-w-full divide-y divide-gray-200">
        <thead>
          <tr>
            <th scope="col" class="px-6 py-3 text-start text-gray-500">
              Name
            </th>
            <th scope="col" class="px-6 py-3 text-start text-gray-500">
              Title
            </th>
            <th scope="col" class="px-6 py-3 text-start text-gray-500">
              Age
            </th>
            <th scope="col" class="px-6 py-3 text-start text-gray-500">
              Email
            </th>
            <th scope="col" class="px-6 py-3 text-start text-gray-500">
              Address
            </th>
            <th scope="col" class="px-6 py-3 text-end text-gray-500">
              Action
            </th>
          </tr>
        </thead>
        <tbody class="divide-y divide-gray-200">
          <tr>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              John Brown
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              Regional Paradigm Technician
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              john@site.com
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              45
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              New York No. 1 Lake Park
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-end">
              <button
                type="button"
                class="inline-flex items-center gap-x-2 font-semibold rounded border border-transparent text-blue-500 hover:text-blue-800 disabled:opacity-50 disabled:pointer-events-none00"
              >
                Delete
              </button>
            </td>
          </tr>

          <tr>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              Jim emerald
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              Forward Response Developer
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              jim@site.com
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              27
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              London No. 1 Lake Park
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-end">
              <button
                type="button"
                class="inline-flex items-center gap-x-2 font-semibold rounded border border-transparent text-blue-500 hover:text-blue-800 disabled:opacity-50 disabled:pointer-events-none00"
              >
                Delete
              </button>
            </td>
          </tr>

          <tr>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              Joe Black
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              Product Directives Officer
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              joe@site.com
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              31
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-gray-800">
              Sidney No. 1 Lake Park
            </td>
            <td class="px-6 py-4 whitespace-nowrap text-end">
              <button
                type="button"
                class="inline-flex items-center gap-x-2 font-semibold rounded border border-transparent text-blue-500 hover:text-blue-800 disabled:opacity-50 disabled:pointer-events-none00"
              >
                Delete
              </button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    """
  end
end
