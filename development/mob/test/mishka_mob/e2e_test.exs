defmodule MishkaMob.E2ETest do
  # The runner `mix e2e` is a script (test/e2e.exs), not part of the app: the pure parts
  # of it are checked here, without a device.
  use ExUnit.Case, async: true

  Code.require_file("../e2e.exs", __DIR__)

  alias MishkaMob.E2E

  @tests ~w(test/device/popover_test.exs test/device/otp_field_test.exs test/device/tooltip_test.exs)

  describe "parse_adb_devices/1" do
    test "keeps the devices that are ready and drops the rest" do
      output = """
      List of devices attached
      * daemon started successfully
      R5CXA23AN1F\tdevice
      emulator-5554\tdevice
      emulator-5556\toffline
      0123456789\tunauthorized
      """

      assert E2E.parse_adb_devices(output) == ["R5CXA23AN1F", "emulator-5554"]
    end

    test "is empty when nothing is attached" do
      assert E2E.parse_adb_devices("List of devices attached\n\n") == []
    end
  end

  describe "pick_devices/2" do
    test "uses every attached device when none is named" do
      assert E2E.pick_devices(["a", "emulator-5554"], []) == {:ok, ["a", "emulator-5554"]}
    end

    test "takes an exact serial or a part of exactly one" do
      attached = ["R5CXA23AN1F", "emulator-5554", "emulator-5556"]

      assert E2E.pick_devices(attached, ["R5CX"]) == {:ok, ["R5CXA23AN1F"]}
      assert E2E.pick_devices(attached, ["emulator-5554"]) == {:ok, ["emulator-5554"]}

      assert E2E.pick_devices(attached, ["5554", "5554", "R5CX"]) ==
               {:ok, ["emulator-5554", "R5CXA23AN1F"]}
    end

    test "refuses a serial that matches nothing or several devices" do
      attached = ["emulator-5554", "emulator-5556"]

      assert {:error, no_match} = E2E.pick_devices(attached, ["R5CX"])
      assert no_match =~ "attached: emulator-5554, emulator-5556"
      assert {:error, several} = E2E.pick_devices(attached, ["emulator"])
      assert several =~ "matches several devices"
    end

    test "says so when nothing is attached" do
      assert {:error, message} = E2E.pick_devices([], [])
      assert message =~ "no Android device is attached"
    end
  end

  describe "resolve_target/2" do
    test "finds a file by file name, module name or bare name" do
      for target <- [
            "popover_test",
            "popover",
            "PopoverTest",
            "Popover",
            "MishkaMob.Device.PopoverTest"
          ] do
        assert E2E.resolve_target(target, @tests) == {:ok, "test/device/popover_test.exs"}
      end

      assert E2E.resolve_target("OtpFieldTest", @tests) == {:ok, "test/device/otp_field_test.exs"}
    end

    test "carries a line number over to the file" do
      assert E2E.resolve_target("popover:61", @tests) == {:ok, "test/device/popover_test.exs:61"}
      assert E2E.resolve_target("test/e2e.exs:3", @tests) == {:ok, "test/e2e.exs:3"}
    end

    test "names the near misses when nothing matches" do
      assert {:error, message} = E2E.resolve_target("tool", @tests)
      assert message =~ "no device test named \"tool\""
      assert message =~ "similar: tooltip_test.exs"
    end

    test "refuses a path that is not there" do
      assert E2E.resolve_target("test/device/nope_test.exs", @tests) ==
               {:error, "test/device/nope_test.exs does not exist"}
    end
  end

  describe "plan/3" do
    test "gives each device one partition of as many as there are devices" do
      assert E2E.plan(["phone", "emulator-5554"], Enum.map(1..54, &"f#{&1}"), nil) ==
               {:ok,
                [
                  %{serial: "phone", index: 1, count: 2},
                  %{serial: "emulator-5554", index: 2, count: 2}
                ]}
    end

    test "one device runs everything as a single partition" do
      assert E2E.plan(["emulator-5554"], ["a", "b"], nil) ==
               {:ok, [%{serial: "emulator-5554", index: 1, count: 1}]}
    end

    test "uses no more devices than there are files" do
      assert E2E.plan(["phone", "emulator-5554"], ["only_test.exs"], nil) ==
               {:ok, [%{serial: "phone", index: 1, count: 1}]}
    end

    test "a shard is one partition of the count on the one device" do
      assert E2E.plan(["emulator-5554"], ["a"], {2, 3}) ==
               {:ok, [%{serial: "emulator-5554", index: 2, count: 3}]}

      assert E2E.plan(["a", "b"], ["a"], {1, 2}) == {:error, "--shard runs on exactly one device"}
    end
  end

  describe "parse_shard/1" do
    test "reads index/count" do
      assert E2E.parse_shard("1/2") == {1, 2}
      assert E2E.parse_shard("3/3") == {3, 3}
    end

    test "refuses what is not a position in the count" do
      for bad <- ["0/2", "3/2", "1", "a/b", "1/2/3", ""] do
        assert E2E.parse_shard(bad) == :error
      end
    end
  end

  describe "parse_summary/1" do
    test "reads a passing run" do
      output = """
      Finished in 253.5 seconds (0.00s async, 253.5s sync)

      Result: 191 passed (191 tests), 3 excluded

      device taps: 410 delivered, 0 dropped and repeated
      """

      assert E2E.parse_summary(output) == %{tests: 191, failures: 0, failed: []}
    end

    test "reads a run with failures, and lists each with where it is" do
      output = """
      Running ExUnit with seed: 1, max_cases: 20
      Including tags: [:device]

        1) test tapping the trigger opens the panel (MishkaMob.Device.PopoverTest)
           test/device/popover_test.exs:12
           Assertion with == failed

        2) test the second (MishkaMob.Device.TooltipTest)
           test/device/tooltip_test.exs:40

      Finished in 9.0 seconds (0.00s async, 9.0s sync)

      Result: 1/3 passed, 1 skipped
      Failed: 2 tests
      """

      assert E2E.parse_summary(output) == %{
               tests: 3,
               failures: 2,
               failed: [
                 "test tapping the trigger opens the panel (MishkaMob.Device.PopoverTest) - test/device/popover_test.exs:12",
                 "test the second (MishkaMob.Device.TooltipTest) - test/device/tooltip_test.exs:40"
               ]
             }
    end

    test "reads colours, an empty run and the format before Elixir 1.20" do
      coloured = "\e[32m\nResult: 5 passed\e[0m\n"
      assert E2E.parse_summary(coloured) == %{tests: 5, failures: 0, failed: []}
      assert E2E.parse_summary("\nResult: 0 tests\n") == %{tests: 0, failures: 0, failed: []}

      assert E2E.parse_summary("\n12 doctests, 191 tests, 1 failure\n") == %{
               tests: 191,
               failures: 1,
               failed: []
             }
    end

    test "has no summary for a run that died before printing one" do
      assert E2E.parse_summary("** (RuntimeError) no device connected\n") == nil
    end
  end
end
