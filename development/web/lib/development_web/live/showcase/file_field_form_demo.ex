defmodule DevelopmentWeb.Showcase.FileFieldFormDemo do
  @moduledoc """
  Shared formatting helpers for the `file_field` Ecto form demo, used by both the schemas and the
  showcase example that renders them.
  """

  @doc "Human-readable size, e.g. `1.4 MB`. Used for the limit copy and the saved summary."
  @spec humanize_bytes(integer() | nil) :: String.t()
  def humanize_bytes(nil), do: "—"
  def humanize_bytes(bytes) when bytes < 1_024, do: "#{bytes} B"
  def humanize_bytes(bytes) when bytes < 1_048_576, do: "#{Float.round(bytes / 1_024, 1)} KB"
  def humanize_bytes(bytes), do: "#{Float.round(bytes / 1_048_576, 1)} MB"

  @doc "The file's extension, lowercased and without the dot (`pdf`, `png`, …)."
  @spec format(String.t() | nil) :: String.t()
  def format(nil), do: "—"

  def format(filename) do
    case Path.extname(filename) do
      "" -> "unknown"
      ext -> ext |> String.trim_leading(".") |> String.downcase()
    end
  end

  @doc "Title-cases an `Ecto.Enum` value for display."
  @spec humanize(atom() | nil) :: String.t()
  def humanize(nil), do: "—"
  def humanize(value), do: value |> to_string() |> String.capitalize()

  @doc """
  Flattens the changeset's file errors into `{filename, message}` pairs.

  The files share one dropzone, so their errors are shown together beneath it — a per-input
  error has nowhere to live when the user never typed the value.
  """
  @spec file_errors(Phoenix.HTML.Form.t()) :: [{String.t(), String.t()}]
  def file_errors(%Phoenix.HTML.Form{source: %Ecto.Changeset{} = changeset}) do
    top =
      for {:files, {msg, opts}} <- changeset.errors, do: {nil, interpolate(msg, opts)}

    nested =
      case Map.get(changeset.changes, :files) do
        list when is_list(list) ->
          for child <- list,
              {_field, {msg, opts}} <- child.errors,
              do: {Ecto.Changeset.get_field(child, :filename), interpolate(msg, opts)}

        _ ->
          []
      end

    Enum.uniq(top ++ nested)
  end

  def file_errors(_form), do: []

  defp interpolate(msg, opts) do
    Enum.reduce(opts, msg, fn {k, v}, acc -> String.replace(acc, "%{#{k}}", to_string(v)) end)
  end
end

defmodule DevelopmentWeb.Showcase.FileFieldFormDemo.Upload do
  @moduledoc """
  One uploaded file, as validated metadata. Never holds the bytes — only what the browser
  reported about the file, so the whole attachment form can be checked without touching disk.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias DevelopmentWeb.Showcase.FileFieldFormDemo, as: Demo

  @extensions ~w(.png .jpg .jpeg .webp .pdf)
  @content_types ~w(image/png image/jpeg image/webp application/pdf)
  @max_bytes 2_000_000

  @primary_key false
  embedded_schema do
    field(:filename, :string)
    field(:content_type, :string)
    field(:byte_size, :integer)
  end

  @spec extensions() :: [String.t()]
  def extensions, do: @extensions

  @spec content_types() :: [String.t()]
  def content_types, do: @content_types

  @spec max_bytes() :: pos_integer()
  def max_bytes, do: @max_bytes

  @spec changeset(upload :: %__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(upload, attrs) do
    upload
    |> cast(attrs, [:filename, :content_type, :byte_size])
    |> validate_required([:filename, :content_type, :byte_size])
    |> validate_format(:filename, ~r/\.(png|jpe?g|webp|pdf)$/i,
      message: "must be one of #{Enum.join(@extensions, ", ")}"
    )
    |> validate_inclusion(:content_type, @content_types, message: "unsupported file type")
    |> validate_number(:byte_size,
      greater_than: 0,
      less_than_or_equal_to: @max_bytes,
      message: "must be at most #{Demo.humanize_bytes(@max_bytes)}"
    )
  end
end

defmodule DevelopmentWeb.Showcase.FileFieldFormDemo.Attachment do
  @moduledoc """
  In-memory attachment form for the styled `file_field` showcase. Backed by an Ecto
  `embedded_schema` + changeset — **validation only, never persisted** (no Repo, no database,
  and the uploaded bytes are discarded on submit rather than written anywhere).

  The `files` embed is not typed by the user: `DevelopmentWeb.Showcase.ComponentLive` copies each
  LiveView upload entry's reported metadata into the params before casting, so the files are
  validated by the same changeset as the text fields instead of by a separate code path.
  `allow_upload/3` still rejects wrong-typed or oversized files at the client and socket level;
  the changeset is the second line, and the one that renders a message under the dropzone.
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias DevelopmentWeb.Showcase.FileFieldFormDemo.Upload

  @categories ~w(invoice contract report other)a
  @max_files 5

  @primary_key false
  embedded_schema do
    field(:title, :string)
    field(:category, Ecto.Enum, values: @categories)
    field(:notes, :string)
    embeds_many(:files, Upload, on_replace: :delete)
  end

  @spec categories() :: [atom()]
  def categories, do: @categories

  @spec max_files() :: pos_integer()
  def max_files, do: @max_files

  @spec changeset(attachment :: %__MODULE__{}, map()) :: Ecto.Changeset.t()
  def changeset(attachment, attrs) do
    attachment
    |> cast(attrs, [:title, :category, :notes])
    |> cast_embed(:files,
      required: true,
      required_message: "attach at least one file — drop up to #{@max_files} on the dropzone"
    )
    |> validate_required([:title, :category])
    |> validate_length(:title, min: 3, max: 60)
    |> validate_length(:notes, max: 200)
    |> validate_length(:files, max: @max_files, message: "at most #{@max_files} files at a time")
  end
end
