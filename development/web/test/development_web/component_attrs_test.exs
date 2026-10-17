defmodule DevelopmentWeb.ComponentAttrsTest do
  @moduledoc """
  A component renders with the attributes it declares.

  An optional attribute with no default is absent from the assigns until the caller gives it,
  and a template that reads `@name` of it raises `KeyError`. Every generated component is
  rendered with its required attributes only; the form fields are also bound to a
  `Phoenix.HTML.FormField`, so a default can never hide the field's own name and value.
  """
  use ExUnit.Case, async: true

  import DevelopmentWeb.HeadlessDOM
  import Phoenix.LiveViewTest

  alias DevelopmentWeb.Components.{
    Banner,
    Carousel,
    CheckboxCard,
    CheckboxField,
    ColorField,
    Combobox,
    DateTimeField,
    Dropdown,
    EmailField,
    FileField,
    FormWrapper,
    Image,
    InputField,
    NativeSelect,
    NumberField,
    PasswordField,
    RadioCard,
    RadioField,
    RangeField,
    SearchField,
    TelField,
    TextField,
    TextareaField,
    ToggleField,
    UrlField
  }

  @fields [
    {EmailField, :email_field},
    {TextField, :text_field},
    {NumberField, :number_field},
    {PasswordField, :password_field},
    {TelField, :tel_field},
    {UrlField, :url_field},
    {SearchField, :search_field},
    {TextareaField, :textarea_field},
    {RangeField, :range_field},
    {InputField, :input},
    {CheckboxField, :checkbox_field},
    {CheckboxField, :group_checkbox},
    {RadioField, :radio_field},
    {RadioField, :group_radio},
    {DateTimeField, :date_time_field},
    {CheckboxCard, :checkbox_card},
    {RadioCard, :radio_card},
    {ColorField, :color_field},
    {FileField, :file_field},
    {NativeSelect, :native_select},
    {ToggleField, :toggle_field}
  ]

  # Components that print the bound field's value in the control's own `value`.
  @valued [
    {EmailField, :email_field},
    {TextField, :text_field},
    {NumberField, :number_field},
    {PasswordField, :password_field},
    {TelField, :tel_field},
    {UrlField, :url_field},
    {SearchField, :search_field},
    {RangeField, :range_field},
    {InputField, :input},
    {DateTimeField, :date_time_field},
    {RadioField, :radio_field}
  ]

  # Every component that changed to draw `rounded="none"`.
  @rounded_none ~w(footer form_wrapper gallery image mega_menu navbar popover progress table
    table_content toggle_field tooltip video)

  defp components do
    {:ok, modules} = :application.get_key(:development, :modules)

    for module <- modules,
        String.starts_with?(Atom.to_string(module), "Elixir.DevelopmentWeb.Components."),
        Code.ensure_loaded?(module),
        function_exported?(module, :__components__, 0),
        {name, info} <- module.__components__(),
        function_exported?(module, name, 1),
        do: {module, name, info}
  end

  defp component(module, name) do
    {^module, ^name, info} =
      Enum.find(components(), fn {m, n, _info} -> m == module and n == name end)

    info
  end

  defp placeholder(%{type: :boolean}), do: true
  defp placeholder(%{type: :list}), do: []
  defp placeholder(%{type: :atom}), do: :x
  defp placeholder(%{type: :integer}), do: 1
  defp placeholder(%{type: :map}), do: %{}
  defp placeholder(_attr), do: "x"

  defp slot_entries(name, attrs) do
    entry = for attr <- attrs, attr.required, into: %{}, do: {attr.name, placeholder(attr)}
    [Map.merge(entry, %{__slot__: name, inner_block: fn _, _ -> "x" end})]
  end

  defp required_assigns(info) do
    attrs = for attr <- info.attrs, attr.required, into: %{}, do: {attr.name, placeholder(attr)}

    slots =
      for slot <- info.slots, slot.required, into: %{} do
        {slot.name, slot_entries(slot.name, slot.attrs)}
      end

    attrs
    |> Map.merge(slots)
    |> Map.put_new(:inner_block, slot_entries(:inner_block, []))
  end

  defp render(module, name, assigns) do
    render_component(Function.capture(module, name, 1), assigns)
  end

  defp render_required(module, name, extra \\ %{}) do
    info = component(module, name)
    render(module, name, Map.merge(required_assigns(info), extra))
  end

  defp class_tokens(html) do
    html
    |> doc()
    |> LazyHTML.query("[class]")
    |> LazyHTML.attribute("class")
    |> Enum.flat_map(&String.split/1)
  end

  defp form_field(params \\ %{"x" => "val"}) do
    Phoenix.Component.to_form(params, as: :f)[:x]
  end

  defp optional_without_default(info) do
    for attr <- info.attrs,
        attr.type != :global,
        not attr.required,
        not Keyword.has_key?(attr.opts, :default),
        do: attr.name
  end

  describe "an optional attribute with no default" do
    test "no component raises KeyError for one when it has only its required attributes" do
      results =
        for {module, name, info} <- components() do
          optional = optional_without_default(info)

          try do
            render(module, name, required_assigns(info))
            :rendered
          rescue
            error in KeyError ->
              if error.key in optional and is_map(error.term) and
                   is_map_key(error.term, :__changed__),
                 do: {:missing, inspect(module), name, error.key},
                 else: :unrenderable

            _error ->
              :unrenderable
          end
        end

      assert Enum.filter(results, &is_tuple/1) == []
      assert Enum.count(results, &(&1 == :rendered)) > 100
    end
  end

  describe "form fields" do
    test "render with no name, value or label, and with a name only" do
      for {module, name} <- @fields do
        assert render_required(module, name) =~ "<", "#{name} without name"
        assert render_required(module, name, %{name: "x"}) =~ ~s(name="x"), "#{name} with name"
      end
    end

    test "take the name of the field they are bound to" do
      for {module, name} <- @fields do
        assert render_required(module, name, %{field: form_field()}) =~ ~s(name="f[x]),
               "#{name} bound to a field"
      end
    end

    test "take the value of the field they are bound to" do
      for {module, name} <- @valued do
        html = render_required(module, name, %{field: form_field()})
        assert html =~ ~s(value="val"), "#{name} bound to a field"
      end
    end

    test "a name and value given to a bound field win over the field's own" do
      for {module, name} <- @valued, name != :radio_field do
        html = render_required(module, name, %{field: form_field(), name: "own", value: "mine"})

        assert html =~ ~s(name="own"), "#{name} name"
        assert html =~ ~s(value="mine"), "#{name} value"
        refute html =~ ~s(value="val"), "#{name} field value"
      end
    end

    test "a toggle bound to a true field is checked" do
      html = render_required(ToggleField, :toggle_field, %{field: form_field(%{"x" => true})})
      assert doc(html) |> has_attr?(~s(input[type="checkbox"]), "checked")
    end

    test "a color field bound to a field shows its color, and #000000 without one" do
      field = form_field(%{"x" => "#ff0000"})
      bound = render_required(ColorField, :color_field, %{field: field})
      assert doc(bound) |> attr(~s(input[type="color"]), "value") == "#ff0000"

      unbound = render_required(ColorField, :color_field, %{name: "x"})
      assert doc(unbound) |> attr(~s(input[type="color"]), "value") == "#000000"
    end

    test "an input of type select renders with no options" do
      html = render_required(InputField, :input, %{type: "select", name: "x"})
      assert doc(html) |> LazyHTML.query("select option") |> Enum.count() == 0
    end

    test "a form wrapper renders with no form" do
      assert render_required(FormWrapper, :form_wrapper) =~ "<form"
    end
  end

  describe "banner edges" do
    @border_top ~w(border-t border-t-2 border-t-[3px] border-t-4 border-t-[5px])
    @border_bottom ~w(border-b border-b-2 border-b-[3px] border-b-4 border-b-[5px])
    @rounded_top ~w(rounded-t-xs rounded-t rounded-t-md rounded-t-lg rounded-t-xl)
    @rounded_bottom ~w(rounded-b-xs rounded-b rounded-b-md rounded-b-lg rounded-b-xl)
    @sizes ~w(extra_small small medium large extra_large)

    defp banner_tokens(assigns) do
      class_tokens(render_required(Banner, :banner, Map.put(assigns, :id, "banner")))
    end

    defp edges(tokens), do: Enum.filter(tokens, &(&1 =~ ~r/^(border|rounded)-[tb](-|$)/))

    test "a banner with no border_position or rounded_position keeps its look" do
      tokens = banner_tokens(%{})

      assert "border-b" in tokens
      assert edges(tokens) == ["border-b"]
      assert tokens == banner_tokens(%{border_position: "bottom", rounded_position: "none"})
    end

    test "border_position names the edge the border is drawn on" do
      for {size, top, bottom} <- Enum.zip([@sizes, @border_top, @border_bottom]) do
        assert edges(banner_tokens(%{border: size, border_position: "top"})) == [top]
        assert edges(banner_tokens(%{border: size, border_position: "bottom"})) == [bottom]
      end
    end

    test "rounded_position names the edge whose corners are rounded" do
      for {size, top, bottom} <- Enum.zip([@sizes, @rounded_top, @rounded_bottom]) do
        top_tokens = banner_tokens(%{rounded: size, rounded_position: "top"})
        bottom_tokens = banner_tokens(%{rounded: size, rounded_position: "bottom"})

        assert top in top_tokens and bottom not in top_tokens, "top #{size}"
        assert bottom in bottom_tokens and top not in bottom_tokens, "bottom #{size}"
      end
    end
  end

  describe "extra_small and small" do
    defp size_tokens(module, name, info, attrs) do
      slots =
        for slot <- info.slots, into: %{}, do: {slot.name, slot_entries(slot.name, slot.attrs)}

      media = if Enum.any?(info.attrs, &(&1.name == :src)), do: %{src: "x"}, else: %{}

      assigns =
        info |> required_assigns() |> Map.merge(slots) |> Map.merge(media) |> Map.merge(attrs)

      module |> render(name, assigns) |> class_tokens() |> Enum.map(&v4_step/1)
    end

    # Tailwind v4 gives a bare `rounded`, `shadow` or `blur` the step of its `-sm`.
    defp v4_step(class) do
      bare =
        ~r/(^|:)(rounded(?:-(?:t|b|s|e|l|r|tl|tr|bl|br|ss|se|es|ee))?|shadow|blur|drop-shadow|backdrop-blur)$/

      Regex.replace(bare, class, "\\1\\2-sm")
    end

    defp same_classes(attr) do
      for {module, name, info} <- components(),
          not String.contains?(inspect(module), ".Headless."),
          Enum.any?(info.attrs, &(&1.name == attr)) do
        try do
          small = size_tokens(module, name, info, %{attr => "small"})
          extra_small = size_tokens(module, name, info, %{attr => "extra_small"})
          {inspect(module), name, small == extra_small}
        rescue
          _error -> {inspect(module), name, :unrenderable}
        end
      end
    end

    test "never render the same rounded classes" do
      results = same_classes(:rounded)

      assert for({module, name, true} <- results, do: {module, name}) == []
      assert Enum.count(results, &(elem(&1, 2) == false)) > 30
    end

    test "never render the same shadow classes" do
      results = same_classes(:shadow)

      assert for({module, name, true} <- results, do: {module, name}) == []
      assert Enum.count(results, &(elem(&1, 2) == false)) >= 2
    end

    test "never render the same blur on an image" do
      blur = fn size -> %{filter: "blur", filter_size: size} end
      info = component(Image, :image)

      assert size_tokens(Image, :image, info, blur.("extra_small")) !=
               size_tokens(Image, :image, info, blur.("small"))
    end
  end

  describe "rounded none" do
    test "is never printed as a class" do
      results =
        for {module, name, info} <- components(),
            Enum.any?(info.attrs, &(&1.name == :rounded)) do
          assigns = Map.put(required_assigns(info), :rounded, "none")

          try do
            {inspect(module), name, "none" in class_tokens(render(module, name, assigns))}
          rescue
            _error -> {inspect(module), name, :unrenderable}
          end
        end

      assert for({module, name, true} <- results, do: {module, name}) == []
      assert Enum.count(results, &(elem(&1, 2) == false)) > 30
    end

    test "draws no radius on the components that gained the clause" do
      for {module, name, info} <- components(),
          Atom.to_string(name) in @rounded_none,
          Enum.any?(info.attrs, &(&1.name == :rounded)) do
        tokens = render(module, name, Map.put(required_assigns(info), :rounded, "none"))
        assert Enum.any?(class_tokens(tokens), &(&1 =~ ~r/rounded(-[a-z])?-none$/)), "#{name}"
      end
    end
  end

  describe "image ismap" do
    test "is a boolean attribute that is off by default" do
      attr = Enum.find(component(Image, :image).attrs, &(&1.name == :ismap))

      assert attr.type == :boolean
      assert attr.opts[:default] == false
    end

    test "is bare when on, and absent when off" do
      on = render_required(Image, :image, %{ismap: true})
      off = render_required(Image, :image, %{ismap: false})

      assert doc(on) |> attr("img", "ismap") == ""
      refute doc(off) |> has_attr?("img", "ismap")
      refute doc(render_required(Image, :image)) |> has_attr?("img", "ismap")
    end
  end

  describe "carousel" do
    defp slide(attrs) do
      [Map.merge(%{__slot__: :slide, inner_block: fn _, _ -> "" end}, attrs)]
    end

    test "a slide without an image renders its title and no picture" do
      html = render_required(Carousel, :carousel, %{id: "c", slide: slide(%{title: "Welcome"})})

      assert html =~ "Welcome"
      refute html =~ "<img"
    end

    test "a slide with an image renders it" do
      html = render_required(Carousel, :carousel, %{id: "c", slide: slide(%{image: "/a.png"})})
      assert doc(html) |> attr("img", "src") == "/a.png"
    end
  end

  describe "range_field" do
    test "a range_value without a position sits at the start" do
      value = [%{__slot__: :range_value, inner_block: fn _, _ -> "$5" end}]
      html = render_required(RangeField, :range_field, %{name: "x", range_value: value})

      assert html =~ "$5"
      assert "start-0" in class_tokens(html)
    end
  end

  describe "combobox id" do
    defp combobox_id(assigns) do
      html = render_required(Combobox, :combobox, assigns)
      doc(html) |> attr("select", "id")
    end

    test "is given, or made from the name, and is the same on every render" do
      assert combobox_id(%{id: "mine", name: "role"}) == "mine"

      for multiple <- [false, true] do
        assigns = %{name: "user[role]", multiple: multiple}
        assert combobox_id(assigns) == "combo-user_role"
        assert combobox_id(assigns) == combobox_id(assigns)
      end
    end

    test "is a combo-prefixed id even with no name" do
      assert "combo-" <> _ = combobox_id(%{})
      assert combobox_id(%{}) != "-combo"
    end
  end

  describe "native_select option" do
    test "disabled is a boolean on every option slot" do
      types =
        for {name, info} <- NativeSelect.__components__(),
            slot <- info.slots,
            slot.name == :option,
            attr <- slot.attrs,
            attr.name == :disabled,
            do: {name, attr.type}

      assert types != []
      assert Enum.all?(types, &(elem(&1, 1) == :boolean))
    end
  end

  describe "file_field" do
    test "documents what live and dropzone need" do
      {:docs_v1, _anno, _lang, _format, _doc, _meta, docs} = Code.fetch_docs(FileField)

      {_key, _anno, _sig, %{"en" => text}, _meta} =
        Enum.find(docs, &match?({{_, :file_field, 1}, _, _, _, _}, &1))

      assert text =~ "`live` needs `upload`"
      assert text =~ "`dropzone` needs `uploads`"
      assert text =~ "`target`"
    end

    test "raises KeyError for a dropzone with no uploads" do
      assert_raise KeyError, fn -> render_required(FileField, :file_field, %{dropzone: true}) end
    end
  end

  describe "dropdown_trigger" do
    test "declares no attribute that it does not read" do
      names = for attr <- component(Dropdown, :dropdown_trigger).attrs, do: attr.name
      refute :trigger_id in names
    end
  end

  describe "documentation examples" do
    test "give a slot only the attributes some component declares for a slot of that name" do
      declared =
        MapSet.new(
          for {_module, _name, info} <- components(),
              slot <- info.slots,
              attr <- slot.attrs,
              do: {Atom.to_string(slot.name), Atom.to_string(attr.name)}
        )

      undeclared =
        for {module, _name, _info} <- components(),
            {slot, attribute} <- documented_slot_attributes(module),
            not MapSet.member?(declared, {slot, attribute}),
            uniq: true,
            do: {inspect(module), slot, attribute}

      assert undeclared == []
    end
  end

  defp documented_slot_attributes(module) do
    {:docs_v1, _anno, _lang, _format, module_doc, _meta, docs} = Code.fetch_docs(module)
    texts = [module_doc | Enum.map(docs, fn {_key, _anno, _sig, doc, _meta} -> doc end)]

    for %{"en" => text} <- texts,
        [{start, length}, {name_start, name_length}] <-
          Regex.scan(~r/<:(\w+)/, text, return: :index),
        rest = binary_part(text, start + length, byte_size(text) - start - length),
        attribute <- tag_attribute_names(rest),
        attribute =~ ~r/^[a-z][a-z0-9_]*$/,
        do: {binary_part(text, name_start, name_length), attribute}
  end

  defp tag_attribute_names(source), do: scan_tag(source, 0, nil, [], [])

  defp scan_tag("", _depth, _quote, word, names), do: finish_name(word, names)
  defp scan_tag(<<">", _rest::binary>>, 0, nil, word, names), do: finish_name(word, names)

  defp scan_tag(<<char, rest::binary>>, depth, quote, word, names) do
    cond do
      quote != nil ->
        scan_tag(rest, depth, if(char == quote, do: nil, else: quote), word, names)

      depth > 0 ->
        scan_tag(rest, depth + brace(char), quote, word, names)

      char in [?", ?'] ->
        scan_tag(rest, depth, char, word, names)

      char == ?{ ->
        scan_tag(rest, depth + 1, quote, word, names)

      char in [?\s, ?\n, ?\t, ?=, ?/] ->
        scan_tag(rest, depth, quote, [], finish_name(word, names))

      true ->
        scan_tag(rest, depth, quote, [char | word], names)
    end
  end

  defp brace(?{), do: 1
  defp brace(?}), do: -1
  defp brace(_char), do: 0

  defp finish_name([], names), do: names
  defp finish_name(word, names), do: [word |> Enum.reverse() |> to_string() | names]
end
