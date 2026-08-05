defmodule DevelopmentWeb.Showcase.Examples.FileField do
  @moduledoc """
  Docs examples for the `file_field` component, taken from the Mishka source docs
  (`mishka/.../docs/forms/file_field_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  The live sections each bind a *different* `allow_upload` name, and every one of them passes an
  explicit `id` — the arrangement that used to leave the dropzone unclickable (issue #496).
  """
  use DevelopmentWeb, :html

  alias DevelopmentWeb.Showcase.FileFieldFormDemo, as: Demo
  alias DevelopmentWeb.Showcase.FileFieldFormDemo.{Attachment, Upload}

  def sections do
    [
      %{id: "base", title: "Form file component"},
      %{id: "multiple", title: "Multiple files, sizes and radius"},
      %{id: "dropzone", title: "Dropzone"},
      %{id: "dropzone_image", title: "Dropzone type, title, icon and description"},
      %{id: "live_label", title: "Live input with a label"},
      %{id: "two_forms", title: "Two forms, two uploads, one page"},
      %{id: "ecto_form", title: "Real form — Ecto validation on a live upload"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.file_field
        :for={c <- ~w(base natural primary secondary success warning danger info dawn)}
        id={"ex-file_field-color-#{c}"}
        name={"color-#{c}"}
        color={c}
        space="small"
        label={String.capitalize(c)}
      />
    </div>
    """
  end

  def example(%{section: "multiple"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <.file_field
        id="ex-file_field-multiple"
        name="multiple"
        color="primary"
        space="small"
        label="Pick as many as you like"
        multiple
      />
      <.file_field
        :for={r <- ~w(none extra_small small medium large extra_large)}
        id={"ex-file_field-rounded-#{r}"}
        name={"rounded-#{r}"}
        color="natural"
        space="small"
        rounded={r}
        label={r}
      />
    </div>
    """
  end

  def example(%{section: "dropzone"} = assigns) do
    ~H"""
    <.form
      for={@form}
      id="ex-file_field-dropzone-form"
      phx-change="validate"
      phx-submit="save"
      class="w-full"
    >
      <.file_field
        id="ex-file_field-dropzone"
        target={:showcase_dropzone_file}
        uploads={@uploads}
        dropzone
        dropzone_type="file"
        variant="outline"
        color="primary"
        dropzone_description="PDF, TXT, MD or ZIP — up to 5 MB each"
      />
    </.form>
    """
  end

  def example(%{section: "dropzone_image"} = assigns) do
    ~H"""
    <.form
      for={@form}
      id="ex-file_field-dropzone-image-form"
      phx-change="validate"
      phx-submit="save"
      class="w-full"
    >
      <.file_field
        id="ex-file_field-dropzone-image"
        target={:showcase_dropzone_image}
        uploads={@uploads}
        dropzone
        dropzone_type="image"
        variant="bordered"
        color="success"
        dropzone_icon="hero-photo"
        dropzone_title="Drop your images here"
        dropzone_description="JPG, PNG, GIF or WEBP — up to 3 files"
      />
    </.form>
    """
  end

  def example(%{section: "live_label"} = assigns) do
    ~H"""
    <.form
      for={@form}
      id="ex-file_field-live-form"
      phx-change="validate"
      phx-submit="save"
      class="w-full"
    >
      <.file_field
        id="ex-file_field-live"
        upload={@uploads.showcase_live_file}
        live
        color="info"
        space="small"
        label="Avatar"
      />
    </.form>
    """
  end

  def example(%{section: "two_forms"} = assigns) do
    ~H"""
    <div class="grid md:grid-cols-2 gap-5">
      <.form
        for={@form}
        id="ex-file_field-form-a"
        phx-change="validate"
        phx-submit="save"
        class="space-y-4"
      >
        <.file_field
          id="ex-file_field-form-a-dropzone"
          target={:showcase_form_a}
          uploads={@uploads}
          dropzone
          dropzone_type="image"
          variant="outline"
          color="primary"
          dropzone_title="Form A — avatar"
        />
        <.file_field
          id="ex-file_field-form-a-plain"
          name="form_a[attachment]"
          color="primary"
          space="small"
          label="Form A — attachment"
        />
      </.form>

      <.form
        for={@form}
        id="ex-file_field-form-b"
        phx-change="validate"
        phx-submit="save"
        class="space-y-4"
      >
        <.file_field
          id="ex-file_field-form-b-dropzone"
          target={:showcase_form_b}
          uploads={@uploads}
          dropzone
          dropzone_type="file"
          variant="outline"
          color="danger"
          dropzone_title="Form B — contract"
        />
        <.file_field
          id="ex-file_field-form-b-plain"
          name="form_b[attachment]"
          color="danger"
          space="small"
          label="Form B — attachment"
        />
      </.form>
    </div>
    """
  end

  def example(%{section: "ecto_form"} = assigns) do
    ~H"""
    <div class="space-y-4">
      <p class="text-xs text-[var(--c-base-content)]/60">
        A real Phoenix form backed by an Ecto <code>embedded_schema</code>. Up to {Attachment.max_files()} files upload at once (<code>auto_upload</code>), and each one is
        validated by the same changeset as the text fields — nothing is written to a database and
        the bytes are discarded on submit. Limits: {Enum.join(Upload.extensions(), " · ")}, max {Demo.humanize_bytes(
          Upload.max_bytes()
        )} each.
      </p>

      <.form
        for={@attachment_form}
        id="ex-file_field-attachment-form"
        phx-change="attachment_validate"
        phx-submit="attachment_save"
        class="space-y-4"
      >
        <.text_field
          field={@attachment_form[:title]}
          id="ex-file_field-attachment-title"
          label="Title"
          space="small"
          size="small"
          color="natural"
          variant="bordered"
          placeholder="Q3 hosting invoice"
        />

        <.native_select
          field={@attachment_form[:category]}
          id="ex-file_field-attachment-category"
          label="Category"
          space="small"
          size="small"
          color="natural"
          variant="bordered"
        >
          <:option value="" selected={selected?(@attachment_form[:category], "")}>
            Choose a category…
          </:option>
          <:option
            :for={{value, label} <- category_options()}
            value={value}
            selected={selected?(@attachment_form[:category], value)}
          >
            {label}
          </:option>
        </.native_select>

        <.textarea_field
          field={@attachment_form[:notes]}
          id="ex-file_field-attachment-notes"
          label="Notes"
          space="small"
          size="small"
          color="natural"
          variant="bordered"
          rows="2"
          placeholder="Anything the reviewer should know (optional, max 200 characters)"
        />

        <div>
          <.file_field
            id="ex-file_field-attachment-dropzone"
            target={:showcase_attachment}
            uploads={@uploads}
            dropzone
            dropzone_type="file"
            variant="outline"
            color={if Demo.file_errors(@attachment_form) == [], do: "primary", else: "danger"}
            dropzone_title={"Drop up to #{Attachment.max_files()} files, or click to choose"}
            dropzone_description={
              "#{Enum.join(Upload.extensions(), " · ")} — max #{Demo.humanize_bytes(Upload.max_bytes())} each"
            }
          />

          <p
            :for={{filename, msg} <- Demo.file_errors(@attachment_form)}
            class="mt-2 text-xs font-medium text-[var(--c-danger)]"
          >
            <span :if={filename} class="font-mono">{filename}:</span>
            {msg}
          </p>
        </div>

        <div class="flex flex-wrap items-center gap-3">
          <button
            type="submit"
            disabled={uploading?(@uploads.showcase_attachment)}
            class={[
              "rounded-md bg-[var(--c-primary)] px-4 py-1.5 text-sm font-medium text-primary-content",
              uploading?(@uploads.showcase_attachment) && "opacity-50 cursor-not-allowed"
            ]}
          >
            Submit
          </button>
          <button
            type="button"
            phx-click="attachment_reset"
            class="rounded-md border border-[var(--c-base-300)] px-4 py-1.5 text-sm"
          >
            Reset
          </button>
          <span class="text-xs text-[var(--c-base-content)]/40">
            Validation only — no database, no stored file.
          </span>
        </div>

        <p :if={@attachment_busy} class="text-xs font-medium text-[var(--c-warning)]">
          Still uploading — wait for every file to finish, then submit again.
        </p>
      </.form>

      <div
        :if={@attachment_saved}
        id="ex-file_field-attachment-result"
        class="rounded-md border border-[var(--c-success)]/40 bg-[var(--c-success)]/10 p-3 text-sm"
      >
        <p class="font-medium text-[var(--c-success)]">
          ✓ Validated {length(@attachment_saved.files)} file(s) — nothing was persisted
        </p>

        <dl class="mt-2 grid grid-cols-[5rem_1fr] gap-x-3 gap-y-1 text-xs">
          <dt class="text-[var(--c-base-content)]/50">Title</dt>
          <dd>{@attachment_saved.title}</dd>
          <dt class="text-[var(--c-base-content)]/50">Category</dt>
          <dd>{Demo.humanize(@attachment_saved.category)}</dd>
        </dl>

        <table class="mt-3 w-full text-xs">
          <thead class="text-[var(--c-base-content)]/50">
            <tr class="text-left">
              <th class="pb-1 font-medium">File name</th>
              <th class="pb-1 font-medium">Format</th>
              <th class="pb-1 font-medium">Content type</th>
              <th class="pb-1 font-medium">Size</th>
            </tr>
          </thead>
          <tbody>
            <tr :for={file <- @attachment_saved.files} data-part="saved-file">
              <td data-part="filename" class="pr-3 font-mono break-all">{file.filename}</td>
              <td data-part="format" class="pr-3 font-mono uppercase">
                {Demo.format(file.filename)}
              </td>
              <td data-part="content-type" class="pr-3 font-mono">{file.content_type}</td>
              <td data-part="size" class="font-mono whitespace-nowrap">
                {Demo.humanize_bytes(file.byte_size)}
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  def example(assigns), do: ~H""

  # `consume_uploaded_entries/3` raises on an entry that is still in flight, and `auto_upload`
  # starts the transfer the moment files are chosen — so the button waits for them.
  defp uploading?(upload), do: Enum.any?(upload.entries, &(not &1.done?))

  defp category_options do
    Enum.map(Attachment.categories(), &{to_string(&1), Demo.humanize(&1)})
  end

  # `native_select` renders `selected` straight from the slot and never compares the option
  # against its own `field` value, so without this the select resets on every re-render.
  defp selected?(field, value) do
    case field.value do
      nil -> value == ""
      current -> to_string(current) == value
    end
  end
end
