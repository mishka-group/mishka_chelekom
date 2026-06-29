defmodule MishkaChelekom.SimpleCSSUtilities do
  @moduledoc """
  Pure Elixir CSS parser for handling imports and CSS manipulation.
  Supports Tailwind CSS 4.x directives and import management.
  """

  @directive_priorities %{
    "@import" => 1,
    "@source" => 2,
    "@plugin" => 3,
    "@tailwind" => 4,
    "@custom-variant" => 5,
    "@theme" => 6
  }

  @doc """
  Adds a CSS import to the content if it doesn't already exist.

  ## Examples

      iex> MishkaChelekom.SimpleCSSUtilities.add_import("@import \\"tailwindcss\\";", "../vendor/mishka.css")
      {:ok, :added, "@import \\"tailwindcss\\";\\n@import \\"../vendor/mishka.css\\";\\n"}

      iex> content = "@import \\"../vendor/mishka.css\\";"
      iex> MishkaChelekom.SimpleCSSUtilities.add_import(content, "../vendor/mishka.css")
      {:ok, :exists, "@import \\"../vendor/mishka.css\\";"}
  """
  def add_import(css_content, import_path, _url_wrap \\ false) do
    css_content = String.trim(css_content)

    cond do
      import_already_exists?(css_content, import_path) ->
        {:ok, :exists, css_content}

      true ->
        updated_content = insert_import(css_content, import_path)
        {:ok, :added, updated_content}
    end
  rescue
    error ->
      {:error, :parse_error, "Failed to parse CSS: #{inspect(error)}"}
  end

  @doc """
  Checks if a specific import already exists in the CSS content.
  Handles various import formats including Tailwind 4 syntax.
  """
  def import_already_exists?(css_content, import_path) do
    normalized_path = normalize_import_path(import_path)
    normalized_content = normalize_import_path(css_content)

    paths_to_check = [import_path, normalized_path] |> Enum.uniq()

    Enum.any?(paths_to_check, fn path ->
      escaped_path = Regex.escape(path)

      import_patterns = [
        ~r/@import\s+["']#{escaped_path}["'](\s+[^;]*)?;/i,
        ~r/@import\s+url\(["']?#{escaped_path}["']?\)(\s+[^;]*)?;/i
      ]

      Enum.any?(import_patterns, fn pattern ->
        Regex.match?(pattern, css_content) || Regex.match?(pattern, normalized_content)
      end)
    end)
  end

  @doc """
  Inserts an import statement at the appropriate location in CSS content.
  Respects Tailwind 4 directive ordering.
  """
  def insert_import(css_content, import_path) do
    import_statement = "@import \"#{import_path}\";"

    insertion_point = find_insertion_point(css_content)

    case insertion_point do
      {:after_directive, position} ->
        insert_at_position(css_content, import_statement, position)

      :at_beginning ->
        if String.trim(css_content) == "" do
          import_statement <> "\n"
        else
          import_statement <> "\n\n" <> css_content
        end
    end
  end

  @doc """
  Validates CSS content for proper Tailwind 4 structure.
  """
  def validate_tailwind_structure(css_content) do
    lines = String.split(css_content, "\n")

    tailwind_import_index =
      Enum.find_index(lines, fn line ->
        String.contains?(line, "@import") && String.contains?(line, "tailwindcss")
      end)

    other_import_indices =
      lines
      |> Enum.with_index()
      |> Enum.filter(fn {line, _idx} ->
        String.contains?(line, "@import") && !String.contains?(line, "tailwindcss")
      end)
      |> Enum.map(fn {_, idx} -> idx end)

    cond do
      is_nil(tailwind_import_index) || other_import_indices == [] ->
        :ok

      Enum.any?(other_import_indices, &(&1 < tailwind_import_index)) ->
        {:error, ["@import 'tailwindcss' should come before other imports"]}

      true ->
        :ok
    end
  end

  # Private helper functions

  defp find_insertion_point(css_content) do
    directives = parse_directives(css_content)

    import_directives = Enum.filter(directives, fn {type, _, _} -> type == "@import" end)

    cond do
      import_directives != [] ->
        {_, _, position} = List.last(import_directives)
        {:after_directive, position}

      directives != [] ->
        highest =
          directives
          |> Enum.min_by(fn {type, _, _} ->
            Map.get(@directive_priorities, type, 999)
          end)

        {_, _, position} = highest
        {:after_directive, position}

      true ->
        :at_beginning
    end
  end

  defp parse_directives(css_content) do
    directive_patterns = [
      {import_regex(), "@import"},
      {~r/@source\s+[^;]+;/i, "@source"},
      {~r/@plugin\s+[^;]+;/i, "@plugin"},
      {~r/@tailwind\s+[^;]+;/i, "@tailwind"},
      {~r/@custom-variant\s+[^;]+;/i, "@custom-variant"},
      {~r/@theme\s*\{[^}]*\}/s, "@theme"}
    ]

    Enum.flat_map(directive_patterns, fn {regex, type} ->
      case Regex.scan(regex, css_content, return: :index) do
        [] ->
          []

        matches ->
          Enum.map(matches, fn [{start, length}] ->
            {type, start, start + length}
          end)
      end
    end)
    |> Enum.sort_by(fn {_, start, _} -> start end)
  end

  defp import_regex do
    ~r/@import\s+(?:url\([^)]+\)|["'][^"']+["'])(?:\s+[^;]*)?;/i
  end

  defp insert_at_position(css_content, import_statement, position) do
    {before, after_content} = String.split_at(css_content, position)

    before_trimmed = String.trim_trailing(before)
    after_trimmed = String.trim_leading(after_content)

    # Group consecutive imports together (no blank line), but always leave exactly one blank
    # line before any following block (e.g. `@theme`/`@source`) — never zero, never more.
    if after_trimmed == "" do
      before_trimmed <> "\n" <> import_statement <> "\n"
    else
      separator = if String.starts_with?(after_trimmed, "@import"), do: "\n", else: "\n\n"
      before_trimmed <> "\n" <> import_statement <> separator <> after_trimmed
    end
  end

  defp normalize_import_path(path) do
    path
    |> String.trim()
    |> String.replace("\\", "/")
    |> String.replace(~r/\/+/, "/")
  end

  @doc """
  Adds import and theme to CSS content.
  Returns the updated CSS content with the import statement and theme.

  ## Examples

      iex> css_content = "@import 'tailwindcss';"
      iex> theme_content = "@theme { --color-primary: blue; }"
      iex> {:ok, updated} = MishkaChelekom.SimpleCSSUtilities.add_import_and_theme(css_content, "../vendor/mishka.css", theme_content)
      {:ok, "@import 'tailwindcss';\n@import \"../vendor/mishka.css\";\n\n@theme { --color-primary: blue; }\n"}
  """
  def add_import_and_theme(css_content, import_path, theme_content) do
    with {:ok, _, content_with_import} <- add_import(css_content, import_path, false) do
      updated_content = ensure_theme_exists(content_with_import, theme_content)
      {:ok, updated_content}
    end
  end

  @doc """
  Ensures theme content exists in the CSS.
  If @theme already exists, it replaces it. Otherwise, appends it.

  ## Examples

      iex> css_content = "@import 'tailwindcss';"
      iex> theme_content = "@theme { --color-primary: blue; }"
      iex> MishkaChelekom.SimpleCSSUtilities.ensure_theme_exists(css_content, theme_content)
      "@import 'tailwindcss';\n\n@theme { --color-primary: blue; }\n"
  """
  def ensure_theme_exists(css_content, theme_content) do
    cleaned_theme =
      theme_content
      |> String.split("\n")
      |> Enum.map(&String.trim_trailing/1)
      |> Enum.join("\n")
      |> String.trim()

    if String.contains?(css_content, "@theme") do
      css_content
      |> String.replace(~r/\n*@theme\s*\{[^}]*\}\n*/s, "\n\n" <> cleaned_theme <> "\n")
    else
      trimmed_content = String.trim_trailing(css_content)
      spacing = if String.ends_with?(trimmed_content, "\n"), do: "\n", else: "\n\n"
      trimmed_content <> spacing <> cleaned_theme <> "\n"
    end
  end

  @doc """
  Reads theme content from a file path.
  Returns {:ok, content} or {:error, reason}.

  ## Examples

      iex> MishkaChelekom.SimpleCSSUtilities.read_theme_content("path/to/theme.css")
      {:ok, "@theme { --color-primary: blue; }"}
  """
  def read_theme_content(theme_path) do
    case File.read(theme_path) do
      {:ok, content} -> {:ok, content}
      {:error, reason} -> {:error, reason}
    end
  end
end
