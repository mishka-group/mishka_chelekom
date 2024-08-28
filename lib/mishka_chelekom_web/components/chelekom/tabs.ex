defmodule MishkaChelekom.Tabs do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def tabs(assigns) do
    ~H"""
    <div class="w-full">
      <div class="relative right-0">
        <ul class="relative flex flex-wrap p-1 list-none rounded-lg bg-blue-50" data-tabs="tabs" role="list">
          <li class="z-30 flex-auto text-center">
            <a class="z-30 flex items-center justify-center w-full px-0 py-1 mb-0 transition-all ease-in-out border-0 rounded-lg cursor-pointer text-slate-700 bg-inherit"
              data-tab-target="" active role="tab" aria-selected="true">
              <span class="ml-1">HTML</span>
            </a>
          </li>
          <li class="z-30 flex-auto text-center">
            <a class="z-30 flex items-center justify-center w-full px-0 py-1 mb-0 transition-all ease-in-out border-0 rounded-lg cursor-pointer text-slate-700 bg-inherit"
              data-tab-target="" role="tab" aria-selected="false">
              <span class="ml-1">React</span>
            </a>
          </li>
          <li class="z-30 flex-auto text-center">
            <a class="z-30 flex items-center justify-center w-full px-0 py-1 mb-0 transition-all ease-in-out border-0 rounded-lg cursor-pointer text-slate-700 bg-inherit"
              data-tab-target="" role="tab" aria-selected="false">
              <span class="ml-1">Vue</span>
            </a>
          </li>
          <li class="z-30 flex-auto text-center">
            <a class="z-30 flex items-center justify-center w-full px-0 py-1 mb-0 transition-all ease-in-out border-0 rounded-lg cursor-pointer text-slate-700 bg-inherit"
              data-tab-target="" role="tab" aria-selected="true">
              <span class="ml-1">Angular</span>
            </a>
          </li>
          <li class="z-30 flex-auto text-center">
            <a class="z-30 flex items-center justify-center w-full px-0 py-1 mb-0 transition-all ease-in-out border-0 rounded-lg cursor-pointer text-slate-700 bg-inherit"
              data-tab-target="" role="tab" aria-selected="true">
              <span class="ml-1">Svelte</span>
            </a>
          </li>
        </ul>
      </div>
    </div>
    """
  end
end
