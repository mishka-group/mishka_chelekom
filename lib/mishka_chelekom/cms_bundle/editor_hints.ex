defmodule MishkaChelekom.CmsBundle.EditorHints do
  @moduledoc """
  Tells the consuming editor which CONTROL an attribute wants, so it does not have to guess.

  ## The problem this removes

  A CMS reading this bundle has to decide what widget to draw for every attribute, and the bundle
  gave it almost nothing to go on: `attr :name, :string` with no values and no doc. MishkaCMS
  therefore guessed from the attribute's NAME — anything called `icon`, `start_icon`, `end_icon` got
  an icon picker.

  Which works until it doesn't. `chelekom-icon` is the one component that is nothing *but* an icon,
  and it calls its attribute `name`. So the single control where a picker matters most got a bare
  text box, and the author had to type `hero-exclamation-triangle` from memory — with a typo
  rendering nothing at all rather than an error.

  Guessing from names cannot be fixed by adding more names. `opts.editor` is the bundle saying it
  outright, and every consumer that honours the hint stops guessing.

  ## What it emits

  `"editor" => "icon"` on an attribute whose value is an icon CLASS NAME. Two rules, both read off
  the component rather than assumed:

    1. the attribute's own name contains `icon` — `icon`, `start_icon`, `dismiss_icon`;
    2. the attribute is `name` on a component whose name ends in `-icon`.

  An attribute that already carries an `editor` hint is left exactly as it is: a hand-written one is
  more specific than anything inferred here.

  ## Why not more hints than icons

  Because these are the ones this bundle can state with certainty. `color`, `url` and `media` are
  also guessed by name downstream, but a `color` attribute in this kit is a design TOKEN
  (`primary`, `natural`) rather than a hex value, and claiming otherwise would draw a colour swatch
  on 60 of the 70 controls that want a dropdown. A wrong hint is worse than no hint, because it
  overrides the consumer's own judgement.
  """

  @doc """
  Adds `opts.editor` where this bundle can state it, leaving every other field alone.
  """
  @spec annotate([map()]) :: [map()]
  def annotate(components) when is_list(components) do
    Enum.map(components, fn component ->
      Map.update(component, "attrs", [], &Enum.map(&1, fn attr -> hint(attr, component) end))
    end)
  end

  defp hint(attr, component) do
    cond do
      not is_map(attr) -> attr
      already_hinted?(attr) -> attr
      icon?(attr, component) -> put_editor(attr, "icon")
      true -> attr
    end
  end

  defp already_hinted?(attr), do: is_binary(get_in(attr, ["opts", "editor"]))

  defp icon?(attr, component) do
    name = to_string(attr["name"])

    String.contains?(name, "icon") or
      (name == "name" and String.ends_with?(to_string(component["name"]), "-icon"))
  end

  defp put_editor(attr, editor) do
    Map.update(attr, "opts", %{"editor" => editor}, &Map.put(&1 || %{}, "editor", editor))
  end
end
