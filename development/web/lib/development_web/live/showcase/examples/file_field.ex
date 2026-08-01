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

  def sections do
    [
      %{id: "base", title: "Form file component"},
      %{id: "multiple", title: "Multiple files, sizes and radius"},
      %{id: "dropzone", title: "Dropzone"},
      %{id: "dropzone_image", title: "Dropzone type, title, icon and description"},
      %{id: "live_label", title: "Live input with a label"},
      %{id: "two_forms", title: "Two forms, two uploads, one page"}
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

  def example(assigns), do: ~H""
end
