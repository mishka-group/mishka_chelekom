defmodule MishkaChelekom.Generators.AssetsThemeTest do
  @moduledoc """
  The `@theme` block of a project's `app.css`, which Chelekom shares with the project (#511): a
  styled generation sets Chelekom's tokens and keeps every other line of the block.
  """
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper

  alias MishkaChelekom.Generators.Assets
  @moduletag :igniter

  @app_css """
  @import "tailwindcss";

  @theme {
      /* Custom font family */
      --font-caveat: "caveat", cursive;

      /* Custom colors from tailwind.config.js */
      --color-brand: #1eb0ff;
      --color-primary: #1eb0ff;
  }
  """

  defp generate(app_css) do
    test_project_with_formatter()
    |> Igniter.create_new_file("assets/css/app.css", app_css)
    |> Assets.setup_styled_css([])
    |> then(&Rewrite.Source.get(&1.rewrite.sources["assets/css/app.css"], :content))
  end

  test "a styled generation keeps the project's own tokens and their comments" do
    app_css = generate(@app_css)

    for kept <- [
          "/* Custom font family */",
          ~s(--font-caveat: "caveat", cursive;),
          "/* Custom colors from tailwind.config.js */",
          "--color-brand: #1eb0ff;",
          "--color-primary: #1eb0ff;"
        ] do
      assert app_css =~ kept
    end

    assert app_css =~ "--color-base-border-light: var(--base-border-light);"
    assert app_css =~ "--color-primary-light: var(--primary-light);"
  end

  test "generating again changes nothing" do
    once = generate(@app_css)
    assert generate(once) == once
  end

  test "a project with no @theme block gets Chelekom's" do
    app_css = generate(~s|@import "tailwindcss";\n|)

    assert app_css =~ "@theme {"
    assert app_css =~ "--color-base-border-light: var(--base-border-light);"
  end
end
