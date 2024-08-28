defmodule MishkaChelekom.Timeline do
  use Phoenix.Component

  @doc type: :component
  attr :id, :string, default: nil, doc: ""
  attr :class, :string, default: nil, doc: ""
  attr :rest, :global, doc: ""

  def timeline(assigns) do
    ~H"""
    <div>
      <div class="ps-2 my-2 first:mt-0">
        <h3 class="text-xs font-medium uppercase text-gray-500">
          1 Aug, 2024
        </h3>
      </div>
      <div class="flex gap-x-3">
        <div class="relative last:after:hidden after:absolute after:top-7 after:bottom-0 after:start-3.5 after:w-px after:-translate-x-[0.5px] after:bg-gray-200">
          <div class="relative z-10 size-7 flex justify-center items-center">
            <div class="size-2 rounded-full bg-gray-400"></div>
          </div>
        </div>
        <div class="grow pt-0.5 pb-8">
          <h3 class="flex gap-x-1.5 font-semibold text-gray-800 text-sm text-sm">
            Test timeline
          </h3>
          <p class="mt-1 text-xs text-gray-600">Dummy description</p>
          <button
            type="button"
            class="mt-1 -ms-1 p-1 inline-flex items-center gap-x-2 text-xs rounded border border-transparent text-gray-500 hover:bg-gray-100 disabled:opacity-50 disabled:pointer-events-none"
          >
            <img
              class="flex-shrink-0 size-4 rounded-full"
              src="../../image/avatar.svg"
              alt="Image Description"
            /> Dummy name
          </button>
        </div>
      </div>
      <div class="flex gap-x-3">
        <div class="relative last:after:hidden after:absolute after:top-7 after:bottom-0 after:start-3.5 after:w-px after:-translate-x-[0.5px] after:bg-gray-200">
          <div class="relative z-10 size-7 flex justify-center items-center">
            <div class="size-2 rounded-full bg-gray-400"></div>
          </div>
        </div>

        <div class="grow pt-0.5 pb-8">
          <h3 class="flex gap-x-1.5 font-semibold text-gray-800 text-sm text-sm">
            Test timeline
          </h3>
          <button
            type="button"
            class="mt-1 -ms-1 p-1 inline-flex items-center gap-x-2 text-xs rounded border border-transparent text-gray-500 hover:bg-gray-100 disabled:opacity-50 disabled:pointer-events-none"
          >
            <span class="flex flex-shrink-0 justify-center items-center size-4 bg-white border -400-200 text-[10px] font-semibold uppercase text-gray-600 rounded-full">
              A
            </span>
            Dummiest name
          </button>
        </div>
        <!-- End Right Content -->
      </div>

      <div class="flex gap-x-3">
        <div class="relative last:after:hidden after:absolute after:top-7 after:bottom-0 after:start-3.5 after:w-px after:-translate-x-[0.5px] after:bg-gray-200">
          <div class="relative z-10 size-7 flex justify-center items-center">
            <div class="size-2 rounded-full bg-gray-400"></div>
          </div>
        </div>

        <div class="grow pt-0.5 pb-8">
          <h3 class="flex gap-x-1.5 font-semibold text-gray-800 text-sm text-sm">
            Test timeline
          </h3>
          <p class="mt-1 text-xs text-gray-600">Dummy description2</p>
          <button
            type="button"
            class="mt-1 -ms-1 p-1 inline-flex items-center gap-x-2 text-xs rounded border border-transparent text-gray-500 hover:bg-gray-100 disabled:opacity-50 disabled:pointer-events-none"
          >
            <img
              class="flex-shrink-0 size-4 rounded-full"
              src="../../image/avatar.svg"
              alt="Image Description"
            /> Dummy name
          </button>
        </div>
        <!-- End Right Content -->
      </div>

      <div class="ps-2 my-2 first:mt-0">
        <h3 class="text-xs font-medium uppercase text-gray-500">
          31 Jul, 2024
        </h3>
      </div>

      <div class="flex gap-x-3">
        <div class="relative last:after:hidden after:absolute after:top-7 after:bottom-0 after:start-3.5 after:w-px after:-translate-x-[0.5px] after:bg-gray-200">
          <div class="relative z-10 size-7 flex justify-center items-center">
            <div class="size-2 rounded-full bg-gray-400"></div>
          </div>
        </div>

        <div class="grow pt-0.5 pb-8">
          <h3 class="flex gap-x-1.5 font-semibold text-gray-800 text-sm text-sm">
            Break
          </h3>
          <p class="mt-1 text-xs text-gray-600">Dummy description...</p>
        </div>
      </div>
    </div>
    """
  end
end
