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

  Each rule reads the same three things: the attribute's own name, the component it belongs to, and
  the shape the bundle already carries for it.

    * `"icon"` — an icon CLASS NAME. The name contains `icon`, or the attribute is `name` on a
      component whose name ends in `-icon`.
    * `"text"` — an OVERRIDE, for a name that carries one of the words the rules below read and then
      qualifies it into something else. `icon_class` styles an icon, `link_title` is the words on a
      link; both are a text box, and both are what a name-based guess gets confidently wrong.
    * `"media"` — a picture from the media library: `src`, `image`, `thumbnail`.
    * `"url"` — an address typed by hand: `href`, `navigate`, `patch`, `link`.
    * `"color"`, `"number"`, `"textarea"` — the form fields whose own component names the control:
      `chelekom-color-field` renders `<input type="color">`, `chelekom-number-field` and
      `chelekom-range-field` render numeric inputs, `chelekom-textarea-field` renders a `<textarea>`.
      All four call the attribute `value`, which is `chelekom-icon`'s blind spot exactly.

  Media is read BEFORE url, so a name that says both — `image_url` — is a picture: what the author
  wants there is the library, not a text box that happens to accept a path.

  ## What it deliberately does not say

  A WRONG HINT IS WORSE THAN NO HINT. An unstated attribute falls back to the consumer's own
  heuristic, which is right most of the time; a stated one is authoritative and cannot be overruled.
  So where the evidence is thin, this emits nothing, and three cases are worth naming:

    * `color`. Ninety-odd attributes are called that and NONE of them holds a colour: they are a
      vocabulary — `primary`, `danger`, `natural` — resolved through a helper into Tailwind classes,
      and they already ship the list of values that makes a dropdown. A swatch there would be wrong
      ninety times to be right zero. The kit has exactly ONE real colour, `chelekom-color-field`'s
      `value`, and that is the only place `"color"` is claimed.
    * Numbers that are already typed. `:integer` and `:float` say it better than a hint can, because
      the type carries `min`, `max` and `step` with it. Only the two `:any`-typed field values are
      stated.
    * `description`, `text`, `title`. The kit's own docs call these "a short description", and they
      render on one line — not enough to claim a textarea.

  An attribute that already carries an `editor` hint is left exactly as it is: a hand-written one is
  more specific than anything inferred here. So is one whose TYPE already decides the control — a
  boolean is a switch whatever it is called, and `icon_animated` is a flag about an icon, not an
  icon — and so is one that ships its own list of values, which is a dropdown the bundle has already
  described in the only way that carries the options with it.
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
      decided_by_type?(attr) -> attr
      from_a_list?(attr) -> attr
      describes_a_control?(attr) -> put_editor(attr, "text")
      icon?(attr, component) -> put_editor(attr, "icon")
      colour?(attr, component) -> put_editor(attr, "color")
      media?(attr) -> put_editor(attr, "media")
      url?(attr, component) -> put_editor(attr, "url")
      number?(attr, component) -> put_editor(attr, "number")
      prose?(attr, component) -> put_editor(attr, "textarea")
      true -> attr
    end
  end

  defp already_hinted?(attr), do: is_binary(get_in(attr, ["opts", "editor"]))

  # A BOOLEAN IS A SWITCH WHATEVER IT IS CALLED, and a struct is a form field. A consumer reads the
  # type before it reads the name, so a name-derived hint on one of these cannot improve the answer
  # — it can only overrule one that was already right. This is why `icon_animated`, a flag that says
  # whether an icon spins, no longer asks the author to pick an icon.
  @settled_by_type ~w(boolean global struct)

  defp decided_by_type?(attr), do: type(attr) in @settled_by_type

  # AN ATTRIBUTE THAT SHIPS ITS OWN VALUES IS A DROPDOWN, and the bundle has already said so in the
  # only way that carries the options with it. Every hint below is authoritative, so claiming one
  # here would REPLACE the list rather than refine it — the widest kind of wrong this module can be.
  defp from_a_list?(attr) do
    case get_in(attr, ["opts", "values"]) do
      values when is_list(values) -> values != []
      _other -> false
    end
  end

  # A CONTROL WORD, THEN A QUALIFIER THAT TAKES IT BACK. `icon_class` styles an icon and
  # `link_title` is the words printed on a link: the name carries the very word every rule below
  # reads, and the attribute is a class list or a caption. Left unstated this is the one case a
  # name-based guess gets confidently wrong — an icon picker on a Tailwind class — so the kit says
  # `text` outright rather than hoping.
  @control_words ~w(icon image media src link url href color colour)
  @qualifiers ~w(class title label text)

  defp describes_a_control?(attr) do
    words = attr |> name() |> String.split(["_", "-"])

    Enum.any?(words, &(&1 in @control_words)) and List.last(words) in @qualifiers
  end

  defp icon?(attr, component) do
    String.contains?(name(attr), "icon") or named_on?(attr, "name", component, "-icon")
  end

  # THE COMPONENT IS THE EVIDENCE, because the attribute's name cannot be. A form field carries
  # whatever the changeset holds, so all four of these declare `attr :value, :any` and no reading of
  # `value` will ever say what goes in it. Their own names say it precisely: `chelekom-color-field`
  # is `<input type="color" value={@value}>`, and `chelekom-textarea-field` is a `<textarea>`.
  defp colour?(attr, component), do: named_on?(attr, "value", component, "-color-field")

  defp number?(attr, component) do
    named_on?(attr, "value", component, "-number-field") or
      named_on?(attr, "value", component, "-range-field")
  end

  defp prose?(attr, component), do: named_on?(attr, "value", component, "-textarea-field")

  # A PICTURE THE AUTHOR PICKS, not an address they type. This kit uses three of these names and
  # every one of them lands in an `<img src>` or a `<video poster>`; `image_url` and `poster` are
  # here because they say the same thing as plainly, and because `image_url` is what makes the
  # order of the two rules matter at all.
  #
  # `srcset` is deliberately absent: it is a LIST of images with width descriptors, which no
  # single-file picker can produce. Matching whole names rather than fragments is what keeps it out,
  # and what keeps `alt` — the sentence describing the picture — out too.
  @media_names ~w(src image image_url thumbnail poster)

  defp media?(attr), do: name(attr) in @media_names

  # AN ADDRESS TYPED BY HAND: `href` is external, `link` is a path (`patch={@link}`), and
  # `navigate`/`patch` are LiveView's own. Read AFTER the picture rule so that a name saying both —
  # `image_url` — resolves to the library rather than to a text box.
  @url_names ~w(href navigate patch link url)

  defp url?(attr, component) do
    name(attr) in @url_names or named_on?(attr, "value", component, "-url-field")
  end

  defp named_on?(attr, attr_name, component, suffix) do
    name(attr) == attr_name and String.ends_with?(to_string(component["name"]), suffix)
  end

  defp name(attr), do: to_string(attr["name"])

  defp type(attr), do: to_string(attr["type"])

  defp put_editor(attr, editor) do
    Map.update(attr, "opts", %{"editor" => editor}, &Map.put(&1 || %{}, "editor", editor))
  end
end
