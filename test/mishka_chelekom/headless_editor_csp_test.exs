defmodule MishkaChelekom.HeadlessEditorCspTest do
  @moduledoc """
  The headless editor draws on a page whose CSP allows no inline `<style>`.

  TipTap 3 injects a `<style data-tiptap-style>` into `<head>` unless it is told not to, and
  `style-src-elem 'self' 'nonce-…'` blocks that element. The engine therefore turns it off, and the
  ProseMirror base rules TipTap would have injected ship in the headless stylesheet instead.
  """
  use ExUnit.Case, async: true

  @js Path.expand("../../priv/assets/js", __DIR__)
  @stylesheet Path.expand("../../priv/assets/css/mishka_chelekom_headless.css", __DIR__)
  @kit Path.expand("../../priv/cms_ui_kits/chelekom_headless.json", __DIR__)

  @engines ~w(editor_tiptap.js editor_code_mirror.js editor_milk_down.js editor_lexical.js)

  defp read_js(file), do: @js |> Path.join(file) |> File.read!()

  defp css do
    @stylesheet |> File.read!() |> String.replace(~r/\s+/, " ")
  end

  describe "the TipTap engine" do
    test "adds no stylesheet unless the developer asks for it" do
      assert read_js("editor_tiptap.js") =~ "injectCSS: config.injectCSS ?? false"
    end

    test "passes the developer's nonce through" do
      assert read_js("editor_tiptap.js") =~ "injectNonce: config.injectNonce"
    end
  end

  describe "the CodeMirror engine" do
    test "puts the developer's nonce on the style element CodeMirror mounts" do
      source = read_js("editor_code_mirror.js")

      assert source =~ "EditorView.cspNonce.of(config.injectNonce)"
      assert source =~ "config.injectNonce ?"
    end
  end

  test "no engine creates a style element or sets a style attribute" do
    for file <- @engines do
      source = read_js(file)

      refute source =~ ~r/createElement\(\s*["']style["']/, "#{file} creates a <style>"
      refute source =~ ~r/setAttribute\(\s*["']style["']/, "#{file} sets a style attribute"
    end
  end

  describe "the headless stylesheet" do
    test "carries the rules TipTap would have injected for .ProseMirror" do
      css = css()
      scope = ".chelekom-editor__surface .ProseMirror"

      for declaration <- [
            "position: relative;",
            "word-wrap: break-word;",
            "white-space: pre-wrap; white-space: break-spaces;",
            "font-variant-ligatures: none;",
            ~s(font-feature-settings: "liga" 0;)
          ] do
        assert css =~ ~r/#{Regex.escape(scope)} \{[^}]*#{Regex.escape(declaration)}/,
               "#{scope} lacks #{declaration}"
      end

      assert css =~ ~r/#{Regex.escape(scope)} \[contenteditable="false"\] \{ white-space: normal;/
      assert css =~ ~r/#{Regex.escape(scope)} pre \{ white-space: pre-wrap;/
    end

    test "carries the gap cursor and hidden selection rules" do
      css = css()
      surface = ".chelekom-editor__surface"

      for selector <- [
            "#{surface} .ProseMirror-gapcursor",
            "#{surface} .ProseMirror-focused .ProseMirror-gapcursor",
            "#{surface} .ProseMirror-gapcursor::after",
            "#{surface} .ProseMirror-hideselection *::selection",
            "#{surface} .ProseMirror-hideselection *::-moz-selection",
            "#{surface} .ProseMirror-hideselection *",
            "#{surface} img.ProseMirror-separator"
          ] do
        assert css =~ selector <> " {", "the stylesheet lacks #{selector}"
      end

      assert css =~ "@keyframes chelekom-editor-cursor-blink"
      assert css =~ "caret-color: transparent;"
    end

    test "declares no colour of its own" do
      [_, editor_rules] = String.split(css(), "/* Editor:", parts: 2)
      declarations = String.replace(editor_rules, ~r{/\*.*?\*/}s, "")

      refute declarations =~ ~r/:[^;{}]*(\bblack\b|\bwhite\b|#[0-9a-fA-F]{3,8}\b|rgba?\()/
    end
  end

  describe "the shipped headless kit" do
    setup do
      %{kit: @kit |> File.read!() |> Jason.decode!()}
    end

    test "ships the engine that adds no stylesheet", %{kit: kit} do
      hook = Enum.find(kit["js_hooks"], &(&1["name"] == "chelekom-headless-editor"))

      assert hook["content"] =~ "injectCSS: config.injectCSS ?? false"
      assert hook["content"] =~ "injectNonce: config.injectNonce"
    end

    test "ships the rules that replace TipTap's stylesheet", %{kit: kit} do
      theme = Enum.find(kit["stylesheets"], &(&1["name"] == "chelekom-headless-theme"))

      assert theme["content"] =~ ".chelekom-editor__surface .ProseMirror-gapcursor"
      assert theme["content"] =~ "@keyframes chelekom-editor-cursor-blink"
    end
  end
end
