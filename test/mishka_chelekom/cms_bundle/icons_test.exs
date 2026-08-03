defmodule MishkaChelekom.CmsBundle.IconsTest do
  @moduledoc """
  The bundle carries the glyphs behind the `hero-*` classes its components name.

  A consumer has no `deps/heroicons` and no Tailwind plugin, so a class alone is a name with no
  picture — it cannot draw a picker, and it cannot emit the mask rule for a class its own pages have
  not rendered yet.
  """
  use ExUnit.Case, async: true

  alias MishkaChelekom.CmsBundle.Icons

  setup do
    dir = Path.join(System.tmp_dir!(), "icons-#{System.unique_integer([:positive])}")
    on_exit(fn -> File.rm_rf(dir) end)
    {:ok, dir: dir}
  end

  defp write!(dir, source, name, svg) do
    path = Path.join([dir, source])
    File.mkdir_p!(path)
    File.write!(Path.join(path, "#{name}.svg"), svg)
  end

  describe "block/1" do
    test "every weight is prefixed and suffixed the way the plugin names it", %{dir: dir} do
      write!(dir, "24/outline", "bell", "<svg>o</svg>")
      write!(dir, "24/solid", "bell", "<svg>s</svg>")
      write!(dir, "20/solid", "bell", "<svg>m</svg>")
      write!(dir, "16/solid", "bell", "<svg>u</svg>")

      block = Icons.block(dir)

      assert block["prefix"] == "hero-"
      assert block["label"] == "Heroicons"
      assert block["glyphs"]["hero-bell"] == "<svg>o</svg>"
      assert block["glyphs"]["hero-bell-solid"] == "<svg>s</svg>"
      assert block["glyphs"]["hero-bell-mini"] == "<svg>m</svg>"
      assert block["glyphs"]["hero-bell-micro"] == "<svg>u</svg>"
    end

    # Outline first, because it is the default weight — and a JSON object does not promise an order.
    test "the weights keep their order", %{dir: dir} do
      write!(dir, "24/outline", "bell", "<svg/>")

      assert Icons.block(dir)["variants"] == [
               ["", "Outline"],
               ["-solid", "Solid"],
               ["-mini", "Mini"],
               ["-micro", "Micro"]
             ]
    end

    # A name only exists in the weights the set actually ships it in — `16/solid` carries fewer icons
    # than the others, and advertising the rest would offer glyphs that render as nothing.
    test "a name absent from a weight is not invented", %{dir: dir} do
      write!(dir, "24/outline", "bell", "<svg/>")
      write!(dir, "24/outline", "clock", "<svg/>")
      write!(dir, "16/solid", "bell", "<svg/>")

      glyphs = Icons.block(dir)["glyphs"]

      assert Map.has_key?(glyphs, "hero-bell-micro")
      refute Map.has_key?(glyphs, "hero-clock-micro")
    end

    # `nil`, not an empty block: a bundle that could not read its icon set and one that genuinely
    # ships none say different things, and only the first is honest.
    test "a missing or empty set answers nil", %{dir: dir} do
      assert Icons.block(Path.join(dir, "nowhere")) == nil

      File.mkdir_p!(Path.join(dir, "24/outline"))
      assert Icons.block(dir) == nil
    end
  end
end
