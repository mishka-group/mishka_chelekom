defmodule MishkaChelekom.HeadlessEditorCspTest do
  @moduledoc """
  The headless editor draws on a page whose CSP allows no inline `<style>`.

  TipTap 3 injects a `<style data-tiptap-style>` into `<head>` unless it is told not to, and
  `style-src-elem 'self' 'nonce-…'` blocks that element. The engine therefore turns it off, and the
  ProseMirror base rules TipTap would have injected are Tailwind classes on the editor's surface,
  not rules in the headless stylesheet.
  """
  use ExUnit.Case, async: true

  alias MishkaChelekom.Generators.Core

  @js Application.app_dir(:mishka_chelekom, "priv/assets/js")
  @template Application.app_dir(:mishka_chelekom, "priv/headless/editor.eex")
  @kit Application.app_dir(:mishka_chelekom, "priv/cms_ui_kits/chelekom_headless.json")

  @engines ~w(editor_tiptap.js editor_code_mirror.js editor_milk_down.js editor_lexical.js)

  defp read_js(file), do: @js |> Path.join(file) |> File.read!()

  # The editor's template and the headless stylesheet, found the way the generator finds them.
  defp template_source do
    {:ok, %{path: path}} = Core.fetch_catalog(Igniter.new(), "editor", :headless)
    File.read!(path)
  end

  defp headless_stylesheet,
    do: File.read!(Core.lib_priv("assets/css/mishka_chelekom_headless.css"))

  defp surface_classes(source) do
    [_, surface] = String.split(source, ~s("chelekom-editor__surface"), parts: 2)
    [classes, _] = String.split(surface, "@surface_class", parts: 2)

    ~r/"([^"]+)"/
    |> Regex.scan(classes, capture: :all_but_first)
    |> List.flatten()
    |> Enum.flat_map(&String.split/1)
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

  describe "the editor's surface" do
    test "carries the ProseMirror base rules TipTap would have injected as Tailwind classes" do
      classes = surface_classes(File.read!(@template))

      for rule <- [
            "[&_.ProseMirror]:relative",
            "[&_.ProseMirror]:break-words",
            "[&_.ProseMirror]:[font-variant-ligatures:none]",
            "[&_.ProseMirror]:[font-feature-settings:'liga'_0]",
            "[&_.ProseMirror_[contenteditable=false]]:whitespace-normal",
            "[&_.ProseMirror_[contenteditable=false]_[contenteditable=true]]:whitespace-pre-wrap",
            "[&_.ProseMirror_pre]:whitespace-pre-wrap",
            "[&_img.ProseMirror-separator]:inline!",
            "[&_.ProseMirror-gapcursor]:hidden",
            "[&_.ProseMirror-gapcursor]:absolute",
            "[&_.ProseMirror-focused_.ProseMirror-gapcursor]:block",
            "[&_.ProseMirror-gapcursor]:after:border-current",
            "[&_.ProseMirror-gapcursor]:after:animate-pulse",
            "[&_.ProseMirror-hideselection_*]:caret-transparent",
            "[&_.ProseMirror-hideselection_*::selection]:bg-transparent"
          ] do
        assert rule in classes, "the surface lacks #{rule}"
      end
    end

    test "merges them with the caller's surface_class after the component's own classes" do
      assert template_source() =~
               ~r/class=\{\[\s*"chelekom-editor__surface",.*\[&_\.ProseMirror-hideselection_\*::selection\]:bg-transparent",\s*@surface_class\s*\]\}/s
    end

    test "uses no arbitrary-keyframes animation, only Tailwind's own" do
      classes = surface_classes(File.read!(@template))

      assert Enum.filter(classes, &(&1 =~ "animate-")) ==
               ["[&_.ProseMirror-gapcursor]:after:animate-pulse"]
    end
  end

  test "the headless stylesheet gains no ProseMirror base rule" do
    css = headless_stylesheet()

    for name <- [
          "gapcursor",
          "hideselection",
          "ProseMirror-separator",
          "ligatures",
          "keyframes chelekom-editor"
        ] do
      refute css =~ name, "the stylesheet mentions #{name}"
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

    test "ships the surface classes that replace TipTap's stylesheet", %{kit: kit} do
      editor = Enum.find(kit["components"], &(&1["name"] == "chelekom-headless-editor"))

      assert editor["template"] =~ "[&_.ProseMirror-gapcursor]:after:animate-pulse"
      assert editor["template"] =~ "[&_.ProseMirror_[contenteditable=false]]:whitespace-normal"
    end

    test "ships a stylesheet without the editor's ProseMirror base rules", %{kit: kit} do
      theme = Enum.find(kit["stylesheets"], &(&1["name"] == "chelekom-headless-theme"))

      refute theme["content"] =~ "ProseMirror-gapcursor"
      refute theme["content"] =~ "chelekom-editor-cursor-blink"
    end
  end
end
