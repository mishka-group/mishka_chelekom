defmodule MishkaChelekom.Generators.AssetsThemeTest do
  @moduledoc """
  The `@theme` block of a project's `app.css`, which Chelekom shares with the project (#511): a
  styled generation sets Chelekom's tokens and keeps every other line of the block.
  """
  use ExUnit.Case
  import MishkaChelekom.ComponentTestHelper

  alias MishkaChelekom.Generators.Assets
  @moduletag :igniter

  @app_css_path "assets/css/app.css"

  # `assets/css/app.css` as `mix phx.new` 1.8 writes it.
  @phoenix_app_css File.read!(Path.expand("../../fixtures/css/phoenix_app.css", __DIR__))

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

  defp generate_igniter(app_css) do
    test_project_with_formatter()
    |> Igniter.create_new_file(@app_css_path, app_css)
    |> Assets.setup_styled_css([])
  end

  defp generate(app_css), do: content(generate_igniter(app_css))

  defp content(igniter),
    do: Rewrite.Source.get(igniter.rewrite.sources[@app_css_path], :content)

  defp tokens do
    {:ok, tokens} = Assets.theme_declarations()
    tokens
  end

  defp token_names do
    {:ok, [theme]} = IgniterCss.get_at_rules("@theme {#{tokens()}}", "theme")
    Enum.map(theme.declarations, &elem(&1, 0))
  end

  defp plain_theme(css) do
    {:ok, [theme]} = IgniterCss.get_at_rules(css, "theme", "")
    theme
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

  test "every token of theme.css is in the project's @theme, at theme.css's value" do
    app_css = generate(@app_css)
    names = Enum.map(plain_theme(app_css).declarations, &elem(&1, 0))

    assert length(token_names()) > 200
    assert token_names() -- names == []

    assert {:ok, %IgniterCss.Outcome{changed: false}} =
             IgniterCss.ensure_at_rule_declarations(app_css, "theme", "", tokens())
  end

  test "the stock Phoenix app.css gets the import and a @theme, and nothing else changes" do
    app_css = generate(@phoenix_app_css)

    assert app_css =~ ~s|@import "../vendor/mishka_chelekom.css";|
    assert plain_theme(app_css).has_block

    {:ok, without_theme} = IgniterCss.remove_at_rule(app_css, "theme", "")

    {:ok, without_import} =
      IgniterCss.remove_import(without_theme.source, "../vendor/mishka_chelekom.css")

    assert without_import.source == @phoenix_app_css
    assert generate(app_css) == app_css
  end

  test "@theme inline is the project's: it stays as it was and the tokens go to a plain @theme" do
    inline = "@theme inline {\n  --font-sans: var(--font-geist-sans);\n}\n"
    app_css = generate(~s|@import "tailwindcss";\n\n| <> inline)

    assert app_css =~ inline

    assert {:ok, [%{declarations: [{"--font-sans", "var(--font-geist-sans)"}]}]} =
             IgniterCss.get_at_rules(app_css, "theme", "inline")

    assert token_names() -- Enum.map(plain_theme(app_css).declarations, &elem(&1, 0)) == []
  end

  test "with @theme inline and @theme both there, the tokens join the plain one" do
    app_css =
      generate("""
      @import "tailwindcss";

      @theme inline {
        --font-sans: var(--font-geist-sans);
      }

      @theme {
        --color-brand: #1eb0ff;
      }
      """)

    assert {:ok, [_inline, _plain]} = IgniterCss.get_at_rules(app_css, "theme")
    assert {"--color-brand", "#1eb0ff"} in plain_theme(app_css).declarations
    assert "--color-primary-light" in Enum.map(plain_theme(app_css).declarations, &elem(&1, 0))
  end

  test "a token Chelekom owns is set back to Chelekom's value" do
    app_css = generate("@theme {\n  --color-primary-light: red;\n}\n")

    assert {"--color-primary-light", "var(--primary-light)"} in plain_theme(app_css).declarations
  end

  test "a CRLF app.css keeps its line endings" do
    app_css = generate(String.replace(@app_css, "\n", "\r\n"))

    refute app_css =~ ~r/[^\r]\n/
    assert app_css =~ "--color-primary-light: var(--primary-light);\r\n"
  end

  test "a project with no app.css gets a notice and no issue" do
    igniter = Assets.setup_styled_css(test_project_with_formatter(), [])

    assert igniter.issues == []
    assert Enum.any?(igniter.notices, &(&1 =~ "Could not find #{@app_css_path}"))
  end
end
