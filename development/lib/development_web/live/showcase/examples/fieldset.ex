defmodule DevelopmentWeb.Showcase.Examples.Fieldset do
  @moduledoc """
  Docs examples for the `fieldset` component, taken from the Mishka source docs
  (`mishka/.../docs/forms/fieldset_live.html.heex`). Section headers, no descriptions.

  Contract used by `DevelopmentWeb.Showcase.ComponentLive`'s lazy examples accordion:
    * `sections/0` → `[%{id, title}]`
    * `example/1` → a function component, matched on the `:section` assign, rendering that section.

  Sections render only while their accordion item is open (LiveView `:if` adds/removes them from
  the DOM), so all examples never render at once.
  """
  use DevelopmentWeb, :html

  def sections do
    [
      %{id: "default", title: "Fieldset component"},
      %{id: "legend", title: "Fieldset legend prop"},
      %{id: "variant", title: "Variant and color"},
      %{id: "spacing", title: "Spacing"}
    ]
  end

  def example(%{section: "default"} = assigns) do
    ~H"""
    <div class="grid md:grid-cols-2 gap-5">
      <.fieldset space="extra_small" id="ex-fieldset-1" legend="News">
        <:control>
          <.checkbox_field
            name="ex_privacy_newsletter"
            value=""
            space="small"
            label="Subscribe to newsletter updates"
            id="ex-privacy-newsletter"
            checked
          />
        </:control>
        <:control>
          <.checkbox_field
            name="ex_privacy_marketing"
            value=""
            space="small"
            label="Allow marketing communications"
            id="ex-privacy-marketing"
          />
        </:control>
        <:control>
          <.checkbox_field
            name="ex_privacy_terms"
            value=""
            space="small"
            label="I accept the terms and conditions"
            id="ex-privacy-terms"
          />
        </:control>
      </.fieldset>

      <.fieldset space="large" id="ex-fieldset-2">
        <:control>
          <.checkbox_field
            name="ex_notification_email"
            value=""
            space="small"
            label="Email notifications"
            id="ex-notification-email"
            color="natural"
          />
        </:control>
        <:control>
          <.checkbox_field
            name="ex_notification_mobile"
            value=""
            space="small"
            label="Mobile notifications"
            id="ex-notification-mobile"
            color="natural"
          />
        </:control>
        <:control>
          <.checkbox_field
            name="ex_notification_web"
            value=""
            space="small"
            label="Browser notifications"
            id="ex-notification-web"
            color="natural"
            checked
          />
        </:control>
      </.fieldset>
    </div>
    """
  end

  def example(%{section: "legend"} = assigns) do
    ~H"""
    <div class="space-y-5">
      <.fieldset space="medium" legend="Grouped" id="ex-fieldset-legend">
        <:control>
          <.checkbox_field
            name="ex_legend_1"
            value=""
            space="small"
            label="Fieldset group of checkboxes"
            id="ex-legend-1"
            color="silver"
          />
        </:control>
        <:control>
          <.checkbox_field
            name="ex_legend_2"
            value=""
            space="small"
            label="Fieldset group of checkboxes"
            id="ex-legend-2"
            color="silver"
          />
        </:control>
        <:control>
          <.checkbox_field
            name="ex_legend_3"
            value=""
            space="small"
            label="Fieldset group of checkboxes"
            id="ex-legend-3"
            color="silver"
            checked
          />
        </:control>
      </.fieldset>
    </div>
    """
  end

  def example(%{section: "variant"} = assigns) do
    ~H"""
    <div class="flex justify-between gap-5">
      <.fieldset space="medium" id="ex-fieldset-dawn">
        <:control>
          <.checkbox_field
            name="ex_dawn_1"
            value=""
            space="small"
            label="group of checkboxes"
            id="ex-dawn-1"
            color="dawn"
          />
        </:control>
        <:control>
          <.checkbox_field
            name="ex_dawn_2"
            value=""
            space="small"
            label="group of checkboxes"
            id="ex-dawn-2"
            color="dawn"
          />
        </:control>
        <:control>
          <.checkbox_field
            name="ex_dawn_3"
            value=""
            space="small"
            label="group of checkboxes"
            id="ex-dawn-3"
            color="dawn"
            checked
          />
        </:control>
      </.fieldset>

      <.fieldset space="large" variant="default" color="info" id="ex-fieldset-info">
        <:control>
          <.checkbox_field
            name="ex_info_1"
            value=""
            space="small"
            label="Fieldset group of checkboxes"
            id="ex-info-1"
            color="natural"
          />
        </:control>
        <:control>
          <.checkbox_field
            name="ex_info_2"
            value=""
            space="small"
            label="Fieldset group of checkboxes"
            id="ex-info-2"
            color="natural"
          />
        </:control>
        <:control>
          <.checkbox_field
            name="ex_info_3"
            value=""
            space="small"
            label="Fieldset group of checkboxes"
            id="ex-info-3"
            color="natural"
            checked
          />
        </:control>
      </.fieldset>
    </div>
    """
  end

  def example(%{section: "spacing"} = assigns) do
    ~H"""
    <div class="grid md:grid-cols-3 gap-5">
      <.fieldset
        :for={s <- ~w(extra_small medium large)}
        space={s}
        legend={s}
        id={"ex-fieldset-space-#{s}"}
      >
        <:control>
          <.checkbox_field
            name={"ex_space_#{s}_1"}
            value=""
            space="small"
            label="First option"
            id={"ex-space-#{s}-1"}
            color="silver"
          />
        </:control>
        <:control>
          <.checkbox_field
            name={"ex_space_#{s}_2"}
            value=""
            space="small"
            label="Second option"
            id={"ex-space-#{s}-2"}
            color="silver"
            checked
          />
        </:control>
      </.fieldset>
    </div>
    """
  end

  def example(assigns), do: ~H""
end
