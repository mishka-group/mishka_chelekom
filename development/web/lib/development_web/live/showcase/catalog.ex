defmodule DevelopmentWeb.Showcase.Catalog do
  @moduledoc """
  Loads Mishka Chelekom component catalog metadata at runtime from the library's
  `priv/components/*.exs` files.

  The library is wired in as a path dependency (see `development/README.md`), so
  `:code.priv_dir(:mishka_chelekom)` resolves (through the `_build` symlink) to the
  live repo source. Editing a component's `.exs` in the repo is reflected here on the
  next request — no recompile needed.

  Each `.exs` is a keyword list keyed by the component atom, e.g.

      [button: [name: "button", category: "general", args: [variant: [...], color: [...]], ...]]
  """

  @visual_dims ~w(variant color size rounded padding space border media_size)a

  @type dim :: %{key: String.t(), values: [String.t()]}
  @type component :: %{
          name: String.t(),
          category: String.t(),
          doc_url: String.t() | nil,
          args: keyword(),
          dims: [dim()]
        }

  @doc "Absolute path to the library's component catalog directory."
  def components_dir do
    Path.join(:code.priv_dir(:mishka_chelekom), "components")
  end

  @doc "All components, sorted by name."
  @spec all() :: [component()]
  def all do
    components_dir()
    |> Path.join("*.exs")
    |> Path.wildcard()
    |> Enum.map(&load/1)
    |> Enum.reject(&is_nil/1)
    |> Enum.sort_by(& &1.name)
  end

  @doc "A single component by name, or nil."
  @spec get(String.t()) :: component() | nil
  def get(name) when is_binary(name), do: Enum.find(all(), &(&1.name == name))

  @doc """
  The previous and next components around `name` in the global (name-sorted) order, for page-to-page
  navigation. Each is `nil` at the ends — no wraparound.
  """
  @spec neighbors(String.t()) :: {component() | nil, component() | nil}
  def neighbors(name) do
    list = all()

    case Enum.find_index(list, &(&1.name == name)) do
      nil -> {nil, nil}
      0 -> {nil, Enum.at(list, 1)}
      i -> {Enum.at(list, i - 1), Enum.at(list, i + 1)}
    end
  end

  @doc "Components grouped and sorted by category."
  @spec by_category() :: [{String.t(), [component()]}]
  def by_category do
    all()
    |> Enum.group_by(& &1.category)
    |> Enum.sort_by(fn {category, _} -> category end)
  end

  @doc "Total component count."
  def count, do: length(all())

  defp load(path) do
    name = Path.basename(path, ".exs")
    {term, _bindings} = Code.eval_file(path)

    cfg =
      cond do
        is_list(term) and Keyword.has_key?(term, String.to_atom(name)) ->
          term[String.to_atom(name)]

        is_list(term) and term != [] ->
          term |> List.first() |> elem(1)

        true ->
          nil
      end

    if cfg do
      args = cfg[:args] || []

      json_attrs = DevelopmentWeb.Showcase.JsonMeta.attrs(name)
      attr_types = Map.new(json_attrs, &{&1.name, &1.type})

      dims =
        for key <- @visual_dims, vals = args[key], is_list(vals) and vals != [] do
          {attr, type} = resolve_attr(key, attr_types)

          %{
            key: Atom.to_string(key),
            attr: attr,
            type: type,
            values: Enum.map(vals, &to_string/1)
          }
        end

      dims =
        (dims ++ extra_dims(name))
        |> Enum.uniq_by(& &1.key)
        |> Enum.reject(&(&1.key in dead_dims(name)))

      %{
        name: name,
        category: to_string(cfg[:category] || "other"),
        doc_url: cfg[:doc_url],
        description: DevelopmentWeb.Showcase.Meta.styled_description(name),
        sibling: DevelopmentWeb.Showcase.Meta.headless_sibling(name),
        args: args,
        dims: dims,
        flags:
          (flags(json_attrs) ++ extra_flags(name))
          |> Enum.uniq_by(& &1.name)
          |> Enum.reject(&(&1.name in dead_flags(name)))
      }
    end
  rescue
    _ -> nil
  end

  defp resolve_attr(:color, types) do
    cond do
      Map.has_key?(types, "color") -> {"color", type_of(types["color"])}
      Map.has_key?(types, "kind") -> {"kind", type_of(types["kind"])}
      true -> {"color", :string}
    end
  end

  defp resolve_attr(key, types) do
    k = Atom.to_string(key)
    {k, type_of(Map.get(types, k, "string"))}
  end

  defp dead_dims("banner"), do: ["size", "space"]
  defp dead_dims("jumbotron"), do: ["size"]
  defp dead_dims("overlay"), do: ["size"]
  defp dead_dims("stepper"), do: ["space"]
  defp dead_dims("card"), do: ["size"]
  defp dead_dims("navbar"), do: ["space"]
  defp dead_dims(_), do: []

  defp dead_flags("clipboard"), do: ["show_status_text", "dynamic_label"]
  defp dead_flags("file_field"), do: ["live"]
  defp dead_flags("dropdown"), do: ["nomobile"]

  defp dead_flags("toggle_field"), do: ["ring", "reverse"]
  defp dead_flags("navbar"), do: ["relative"]
  defp dead_flags(_), do: []

  defp extra_dims("banner") do
    [
      %{
        key: "border",
        attr: "border",
        type: :string,
        values: ~w(none extra_small small medium large extra_large)
      }
    ]
  end

  defp extra_dims("input_field") do
    [
      %{
        key: "type",
        attr: "type",
        type: :string,
        values:
          ~w(text email password number search tel url date time color range select checkbox textarea file)
      }
    ]
  end

  defp extra_dims("indicator") do
    [
      %{
        key: "position",
        attr: "position",
        type: :string,
        values:
          ~w(none top_left top_center top_right middle_left middle_right bottom_left bottom_center bottom_right)
      }
    ]
  end

  defp extra_dims("divider") do
    [
      %{key: "type", attr: "type", type: :string, values: ~w(solid dashed dotted)},
      %{key: "variation", attr: "variation", type: :string, values: ~w(horizontal vertical)},
      %{key: "position", attr: "position", type: :string, values: ~w(left middle right)}
    ]
  end

  defp extra_dims("stat") do
    [
      %{key: "trend", attr: "trend", type: :string, values: ~w(none up down neutral)},
      %{key: "figure_position", attr: "figure_position", type: :string, values: ~w(start end top)}
    ]
  end

  defp extra_dims("stepper") do
    [
      %{
        key: "current",
        attr: "current",
        type: :integer,
        kind: :range,
        min: 1,
        max: 4,
        step: 1,
        default: 2,
        values: []
      }
    ]
  end

  defp extra_dims("table") do
    [%{key: "text_position", attr: "text_position", type: :string, values: ~w(left center right)}]
  end

  defp extra_dims("gallery") do
    [
      %{key: "type", attr: "type", type: :string, values: ~w(default masonry featured)},
      %{key: "cols", attr: "cols", type: :string, values: ~w(two three four)},
      %{
        key: "gap",
        attr: "gap",
        type: :string,
        values: ~w(extra_small small medium large extra_large)
      }
    ]
  end

  defp extra_dims("image") do
    [
      %{
        key: "filter",
        attr: "filter",
        type: :string,
        values: ~w(none grayscale sepia invert blur brightness contrast saturation hue)
      }
    ]
  end

  defp extra_dims("spinner") do
    [%{key: "type", attr: "type", type: :string, values: ~w(default dots bars pinging)}]
  end

  defp extra_dims("shape") do
    [
      %{
        key: "variant",
        attr: "variant",
        type: :string,
        values:
          ~w(squircle circle square heart star star_alt diamond pentagon hexagon hexagon_alt decagon triangle triangle_down triangle_left triangle_right)
      },
      %{key: "half", attr: "half", type: :string, values: ~w(none first second)}
    ]
  end

  defp extra_dims("rating") do
    [
      %{
        key: "select",
        attr: "select",
        type: :float,
        kind: :range,
        min: 0,
        max: 5,
        step: 0.5,
        default: 2,
        values: []
      },
      %{key: "precision", attr: "precision", type: :string, values: ~w(full half)}
    ]
  end

  defp extra_dims("progress") do
    [
      %{
        key: "value",
        attr: "value",
        type: :integer,
        kind: :range,
        min: 0,
        max: 100,
        step: 5,
        default: 50,
        values: []
      },
      %{
        key: "type",
        attr: "type",
        type: :string,
        values: ~w(horizontal vertical ring semi_circle)
      }
    ]
  end

  defp extra_dims("layout") do
    [
      %{
        key: "direction",
        attr: "direction",
        type: :string,
        values: ~w(row row-reverse col col-reverse)
      },
      %{
        key: "justify",
        attr: "justify",
        type: :string,
        values: ~w(start center end between around evenly)
      },
      %{
        key: "align",
        attr: "align",
        type: :string,
        values: ~w(start center end stretch baseline)
      },
      %{
        key: "gap",
        attr: "gap",
        type: :string,
        values: ~w(extra_small small medium large extra_large)
      },
      %{key: "wrap", attr: "wrap", type: :string, values: ~w(nowrap wrap wrap-reverse)}
    ]
  end

  defp extra_dims("breadcrumb") do
    [
      %{
        key: "separator_icon",
        attr: "separator_icon",
        type: :string,
        values:
          ~w(hero-chevron-right hero-arrow-right hero-slash hero-chevron-double-right hero-minus)
      }
    ]
  end

  defp extra_dims("dock") do
    [
      %{
        key: "border",
        attr: "border",
        type: :string,
        values: ~w(none extra_small small medium large extra_large)
      },
      %{
        key: "position",
        attr: "position",
        type: :string,
        values:
          ~w(static sticky_bottom sticky_top fixed_bottom fixed_top fixed_bottom_center fixed_top_center)
      },
      %{
        key: "max_width",
        attr: "max_width",
        type: :string,
        values: ~w(extra_small small medium large extra_large full)
      }
    ]
  end

  defp extra_dims("footer") do
    [
      %{
        key: "text_position",
        attr: "text_position",
        type: :string,
        values: ~w(left center right)
      },
      %{
        key: "border",
        attr: "border",
        type: :string,
        values: ~w(none extra_small small medium large extra_large)
      }
    ]
  end

  defp extra_dims("mega_menu") do
    [
      %{
        key: "top_gap",
        attr: "top_gap",
        type: :string,
        values: ~w(none extra_small small medium large extra_large)
      },
      %{key: "width", attr: "width", type: :string, values: ~w(full half)},
      %{
        key: "border",
        attr: "border",
        type: :string,
        values: ~w(none extra_small small medium large extra_large)
      }
    ]
  end

  defp extra_dims("navbar") do
    [
      %{
        key: "content_position",
        attr: "content_position",
        type: :string,
        values: ~w(start center end between around)
      },
      %{
        key: "border",
        attr: "border",
        type: :string,
        values: ~w(none extra_small small medium large extra_large)
      }
    ]
  end

  defp extra_dims("pagination") do
    [
      %{
        key: "active",
        attr: "active",
        type: :integer,
        kind: :range,
        min: 1,
        max: 20,
        step: 1,
        default: 1,
        values: []
      },
      %{
        key: "total",
        attr: "total",
        type: :integer,
        kind: :range,
        min: 1,
        max: 20,
        step: 1,
        default: 10,
        values: []
      },
      %{
        key: "siblings",
        attr: "siblings",
        type: :integer,
        kind: :range,
        min: 0,
        max: 4,
        step: 1,
        default: 1,
        values: []
      },
      %{
        key: "boundaries",
        attr: "boundaries",
        type: :integer,
        kind: :range,
        min: 0,
        max: 3,
        step: 1,
        default: 1,
        values: []
      }
    ]
  end

  defp extra_dims("scroll_area") do
    [%{key: "type", attr: "type", type: :string, values: ~w(auto hover never)}]
  end

  defp extra_dims("sidebar") do
    [
      %{
        key: "border",
        attr: "border",
        type: :string,
        values: ~w(none extra_small small medium large extra_large)
      },
      %{key: "position", attr: "position", type: :string, values: ~w(start end)},
      %{key: "hide_position", attr: "hide_position", type: :string, values: ~w(left right)}
    ]
  end

  defp extra_dims("drawer") do
    [%{key: "position", attr: "position", type: :string, values: ~w(left right top bottom)}]
  end

  defp extra_dims("overlay") do
    [
      %{
        key: "opacity",
        attr: "opacity",
        type: :string,
        values:
          ~w(transparent translucent semi_transparent lightly_tinted tinted heavily_tinted semi_opaque opaque almost_solid solid)
      },
      %{
        key: "backdrop",
        attr: "backdrop",
        type: :string,
        values: ~w(extra_small small medium large extra_large)
      }
    ]
  end

  defp extra_dims("popover") do
    [
      %{key: "position", attr: "position", type: :string, values: ~w(top bottom left right)},
      %{
        key: "width",
        attr: "width",
        type: :string,
        values:
          ~w(extra_small small medium large extra_large double_large triple_large quadruple_large)
      },
      %{
        key: "text_position",
        attr: "text_position",
        type: :string,
        values: ~w(start center end left right justify)
      }
    ]
  end

  defp extra_dims("tooltip") do
    [%{key: "position", attr: "position", type: :string, values: ~w(top bottom left right)}]
  end

  defp extra_dims("dropdown") do
    [%{key: "position", attr: "position", type: :string, values: ~w(bottom top left right)}]
  end

  defp extra_dims(_), do: []

  defp extra_flags("indicator"), do: [%{name: "pinging", default: false}]
  defp extra_flags("skeleton"), do: [%{name: "animated", default: true}]

  defp extra_flags("pagination") do
    [
      %{name: "show_edges", default: false},
      %{name: "grouped", default: false},
      %{name: "hide_controls", default: false}
    ]
  end

  defp extra_flags(_), do: []

  defp type_of("atom"), do: :atom
  defp type_of(_), do: :string

  @flag_blocklist ~w(disabled required readonly checked)

  defp flags(json_attrs) do
    for a <- json_attrs, a.type == "boolean", a.name not in @flag_blocklist do
      %{name: a.name, default: a.default in [true, "true"]}
    end
  end
end
