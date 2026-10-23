defmodule MishkaMob.DeviceCase do
  @moduledoc """
  Case template for tests that drive the real app on a phone.

      defmodule MishkaMob.Device.PopoverTest do
        use MishkaMob.DeviceCase, page: :popover

        test "tapping the trigger opens the panel" do
          tap("pop-trigger-closed")
          assert_shown("pop-panel")
        end
      end

  `use` does five things:

    * tags the module `:device`, which `test_helper.exs` excludes, so a plain
      `mix test` never goes near a phone. `mix test --only device` runs them;
    * connects to the running app once per module (`MishkaMob.Device.connect!/0`),
      failing with what to do if it is not there or is an older build;
    * imports `MishkaMob.Device`, the helpers (`tap/2`, `hold/3`, `drag/2`,
      `type/1`, `frame/1`, `scroll_into_view/2`, `assert_shown/2`,
      `refute_shown/2`, `assert_eventually/2`, ...);
    * with `page: :slug`, remounts that component's showcase page before every
      test (`MishkaMob.Device.fresh_page/2`), so each test starts from the same
      screen, assigns, scroll offset and theme. Override per test with
      `@tag page: :other`, or opt out with `@tag page: nil`;
    * runs the module serially (`async: false`): there is one phone.

  `tap/2` shadows `Kernel.tap/2`, so that one is not imported.
  """

  use ExUnit.CaseTemplate

  using opts do
    page = Keyword.get(opts, :page)

    quote do
      @moduletag :device
      # A tap that hangs on a dead phone should say so, not sit out a minute.
      @moduletag timeout: 30_000
      @moduletag page: unquote(page)

      import Kernel, except: [tap: 2]
      import MishkaMob.Device
    end
  end

  setup_all do
    MishkaMob.Device.connect!()
    :ok
  end

  setup context do
    case context[:page] do
      nil -> :ok
      slug -> MishkaMob.Device.fresh_page(slug)
    end
  end
end
