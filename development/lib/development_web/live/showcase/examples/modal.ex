defmodule DevelopmentWeb.Showcase.Examples.Modal do
  @moduledoc """
  Docs examples for the `modal` component, taken from the Mishka source docs
  (`mishka/.../docs/modal_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.

  The doc drives each modal from a trigger button via `Modal.show_modal/1` (a JS command).
  Those JS-command triggers are intentionally dropped here; instead each modal is rendered with
  the literal `show={true}` prop so its built-in `phx-mounted` opens it inline in the showcase
  LiveView — keeping every example self-contained with only literal prop values.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "base", title: "Base color & variant"},
      %{id: "variants", title: "Variants"},
      %{id: "colors", title: "Colors"},
      %{id: "sizes", title: "Sizes"},
      %{id: "padding", title: "Padding"},
      %{id: "rounded", title: "Rounded"}
    ]
  end

  def example(%{section: "base"} = assigns) do
    ~H"""
    <div>
      <.modal id="ex-modal-base" title="Base variant misc color" show={true}>
        <div class="space-y-4">
          <p>
            Mishka Chelekom is a fully-featured UI kit designed for Phoenix LiveView applications.
            It offers a wide range of customizable components to enhance the user experience.
          </p>
        </div>
      </.modal>
    </div>
    """
  end

  def example(%{section: "variants"} = assigns) do
    ~H"""
    <div>
      <.modal
        id="ex-modal-default"
        title="Default variant misc color"
        color="misc"
        variant="default"
        show={true}
      >
        <div class="space-y-4">
          <p>
            The default style applies a solid background and border, making it perfect for
            delivering important notifications.
          </p>
        </div>
      </.modal>
    </div>
    """
  end

  def example(%{section: "colors"} = assigns) do
    ~H"""
    <div>
      <.modal
        id="ex-modal-color-primary"
        title="Primary default modal"
        color="primary"
        variant="default"
        show={true}
      >
        <div class="space-y-4">
          <p>
            Select from a range of color options, ensuring easy customization to match various
            design styles.
          </p>
        </div>
      </.modal>
    </div>
    """
  end

  def example(%{section: "sizes"} = assigns) do
    ~H"""
    <div>
      <.modal
        id="ex-modal-size"
        title="Triple large size"
        color="danger"
        variant="default"
        size="triple_large"
        show={true}
      >
        <div class="space-y-4 max-w-3xl mx-auto">
          <p>
            The size prop defines the overall size of the modal, including aspects like padding,
            font size, and layout.
          </p>
        </div>
      </.modal>
    </div>
    """
  end

  def example(%{section: "padding"} = assigns) do
    ~H"""
    <div>
      <.modal
        id="ex-modal-padding"
        title="Extra large modal padding prop"
        color="primary"
        variant="default"
        padding="extra_large"
        show={true}
      >
        <div class="space-y-4">
          <p>
            The padding prop controls the internal spacing around the content within the modal.
          </p>
        </div>
      </.modal>
    </div>
    """
  end

  def example(%{section: "rounded"} = assigns) do
    ~H"""
    <div>
      <.modal
        id="ex-modal-rounded"
        title="Extra large radius"
        color="silver"
        variant="default"
        rounded="extra_large"
        show={true}
      >
        <div class="space-y-4">
          <p>
            The rounded prop controls the border radius of the modal, determining how rounded the
            corners of the modal are.
          </p>
        </div>
      </.modal>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
