defmodule DevelopmentWeb.ShowcaseKit do
  @moduledoc """
  A real `MishkaChelekom.Kit` for the showcase "Customize it" section: each `customize :<name>_kit`
  adds a new `:brand` color (Tailwind FUCHSIA — not in the component palette) to the real component
  via `from`, targeting the SAME element the component colors. Classes win with a trailing `!`.
  """
  use MishkaChelekom.Kit

  customize :alert_kit do
    from :alert
    kind :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"
    kind :cocoa, "bg-amber-900! text-amber-50! border-amber-900!"
    variant :glow, "ring-2! ring-fuchsia-300! shadow-lg! shadow-fuchsia-500/60!"
    default kind: :brand
  end

  customize :accordion_kit do
    from :accordion

    color :brand,
          "bg-fuchsia-600! text-white! [&>.accordion-item>.accordion-trigger]:hover:bg-fuchsia-700!"

    default color: :brand
  end

  customize :avatar_kit do
    from :avatar
    color :brand, "bg-fuchsia-100! text-fuchsia-600! border-fuchsia-600!"
    default color: :brand
  end

  customize :badge_kit do
    from :badge
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"

    # variant×color PAIR — fires ONLY for variant="bordered" AND color="success".
    variant :bordered,
            "bg-emerald-100! text-emerald-700! border-emerald-600!",
            color: :success

    default color: :brand
  end

  customize :banner_kit do
    from :banner
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"
    default color: :brand
  end

  customize :blockquote_kit do
    from :blockquote
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"
    default color: :brand
  end

  customize :breadcrumb_kit do
    from :breadcrumb
    # @class lands on the <nav>; the component colours the <ol> (text-* + ol>li a hover),
    # so scope through the ol from the root — a bare text-* on nav loses to the ol's own text-*.
    color :brand, "[&>ol]:text-fuchsia-600! [&>ol>li_a]:hover:text-fuchsia-500!"
    default color: :brand
  end

  customize :button_kit do
    from :button
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600! hover:bg-fuchsia-500!"

    # variant×color PAIR — fires ONLY for variant="outline" AND color="danger".
    # cyan is NOT a Mishka palette colour — injected just for this one combo.
    variant :outline,
            "border-2! border-cyan-500! text-cyan-600! bg-transparent! hover:bg-cyan-50!",
            color: :danger

    default color: :brand
  end

  customize :card_kit do
    from :card
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"
    default color: :brand
  end

  customize :carousel_kit do
    from :carousel
    color :brand, "[&_.carousel-overlay]:bg-fuchsia-600/30! text-white!"
    default color: :brand
  end

  customize :chat_kit do
    from :chat
    color :brand, "[&>.chat-section-bubble]:bg-fuchsia-600! [&>.chat-section-bubble]:text-white!"
    default color: :brand
  end

  customize :checkbox_card_kit do
    from :checkbox_card

    color :brand,
          "[&_.checkbox-card-wrapper]:bg-fuchsia-600! [&_.checkbox-card-wrapper]:text-white! [&_.checkbox-card-wrapper]:has-[:checked]:bg-fuchsia-700! [&_.checkbox-card-input]:border-fuchsia-600! [&_.checkbox-card-input]:checked:accent-fuchsia-600!"

    default color: :brand
  end

  customize :checkbox_field_kit do
    from :checkbox_field

    color :brand,
          "text-fuchsia-600! [&_.checkbox-field-wrapper_.checkbox-input]:checked:accent-fuchsia-600! [&_.checkbox-field-wrapper_.checkbox-input]:border-fuchsia-600! [&_.checkbox-field-wrapper:focus-within_.checkbox-input]:ring-fuchsia-500!"

    default color: :brand
  end

  customize :color_field_kit do
    from :color_field
    color :brand, "[&_.color-input]:border-fuchsia-600! dark:[&_.color-input]:border-fuchsia-500!"
    default color: :brand
  end

  customize :combobox_kit do
    from :combobox

    color :brand,
          "[&_.combobox-trigger]:bg-fuchsia-600! [&_.combobox-trigger]:text-white! [&_.combobox-option]:hover:bg-fuchsia-700! [&_.combobox-option]:hover:text-white! [&_.combobox-pill]:bg-fuchsia-700! [&_.combobox-pill]:text-white!"

    default color: :brand
  end

  customize :date_time_field_kit do
    from :date_time_field

    color :brand,
          "[&_.date-time-field-wrapper]:bg-fuchsia-600! [&_.date-time-field-wrapper]:border-fuchsia-600! [&_.date-time-field-wrapper]:text-white! text-fuchsia-600!"

    default color: :brand
  end

  customize :device_mockup_kit do
    from :device_mockup

    color :brand,
          "[&_.mock-base]:bg-fuchsia-600! [&_.mock-base]:border-fuchsia-500! [&_.mock-darker-base]:bg-fuchsia-700!"

    default color: :brand
  end

  customize :divider_kit do
    from :divider

    color :brand,
          "border-fuchsia-500! text-fuchsia-500! has-[.divider-content.divider-middle]:before:border-fuchsia-500! has-[.divider-content.divider-middle]:after:border-fuchsia-500! has-[.divider-content.divider-right]:before:border-fuchsia-500! has-[.divider-content.divider-left]:after:border-fuchsia-500!"

    default color: :brand
  end

  customize :dock_kit do
    from :dock
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"
    default color: :brand
  end

  customize :drawer_kit do
    from :drawer
    color :brand, "[&>div:last-child]:bg-fuchsia-600! [&>div:last-child]:text-white!"
    default color: :brand
  end

  customize :dropdown_kit do
    from :dropdown

    color :brand,
          "[&_.dropdown-content]:bg-fuchsia-600! [&_.dropdown-content]:text-white! [&_.dropdown-content]:border-fuchsia-600!"

    default color: :brand
  end

  customize :email_field_kit do
    from :email_field

    color :brand,
          "[&_.email-field-wrapper]:border-fuchsia-600! [&_.email-field-wrapper]:bg-fuchsia-50! [&_.email-field-wrapper]:text-fuchsia-600! [&_.email-field-wrapper>input]:placeholder:text-fuchsia-500! focus-within:[&_.email-field-wrapper]:ring-fuchsia-600!"

    default color: :brand
  end

  customize :fieldset_kit do
    from :fieldset

    color :brand,
          "[&_.fieldset-field]:bg-fuchsia-600! [&_.fieldset-field]:border-fuchsia-600! [&_.fieldset-legend]:bg-fuchsia-600! text-white!"

    default color: :brand
  end

  customize :file_field_kit do
    from :file_field

    color :brand,
          "[&_.file-field]:bg-fuchsia-500! [&_.file-field]:text-white! [&_.file-field]:file:text-white! [&_.file-field]:file:bg-fuchsia-600!"

    default color: :brand
  end

  customize :footer_kit do
    from :footer
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"
    default color: :brand
  end

  customize :form_wrapper_kit do
    from :form_wrapper
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"
    default color: :brand
  end

  customize :indicator_kit do
    from :indicator
    color :brand, "bg-fuchsia-600! dark:bg-fuchsia-500!"
    default color: :brand
  end

  customize :jumbotron_kit do
    from :jumbotron

    color :brand,
          "bg-fuchsia-600! text-white! border-fuchsia-600! dark:bg-fuchsia-500! dark:text-white! dark:border-fuchsia-500!"

    default color: :brand
  end

  customize :keyboard_kit do
    from :keyboard
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"
    default color: :brand
  end

  customize :list_kit do
    from :list

    color :brand,
          "text-fuchsia-600! border-fuchsia-600! [&>li:not(:last-child)]:border-fuchsia-600!"

    default color: :brand
  end

  customize :mega_menu_kit do
    from :mega_menu

    color :brand,
          "[&>.mega-menu-content]:bg-fuchsia-600! [&>.mega-menu-content]:border-fuchsia-600! text-white!"

    default color: :brand
  end

  customize :modal_kit do
    from :modal
    color :brand, "[&_.transition]:bg-fuchsia-600! [&_.transition]:text-white!"
    default color: :brand
  end

  customize :native_select_kit do
    from :native_select

    color :brand,
          "[&_.select-field:not(:has(.select-field-error))]:bg-fuchsia-600! [&_.select-field]:text-white! focus-within:[&_.select-field]:ring-fuchsia-500!"

    default color: :brand
  end

  customize :navbar_kit do
    from :navbar
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"
    default color: :brand
  end

  customize :number_field_kit do
    from :number_field

    color :brand,
          "[&_.number-field-wrapper]:bg-fuchsia-600! [&_.number-field-wrapper]:border-fuchsia-600! text-fuchsia-600! [&_.number-field-wrapper>input]:text-white!"

    default color: :brand
  end

  customize :overlay_kit do
    from :overlay

    color :brand,
          "bg-fuchsia-600/[var(--overlay-opacity)]! dark:bg-fuchsia-500/[var(--overlay-opacity)]!"

    default color: :brand
  end

  customize :pagination_kit do
    from :pagination

    color :brand,
          "[&_.pagination-button]:bg-fuchsia-600! [&_.pagination-button]:text-white! [&_.pagination-button]:hover:bg-fuchsia-500! [&_.pagination-button.active-pagination-button]:bg-fuchsia-500!"

    default color: :brand
  end

  customize :password_field_kit do
    from :password_field

    color :brand,
          "[&_.password-field-wrapper]:bg-fuchsia-600! [&_.password-field-wrapper]:border-fuchsia-600! [&_.password-field-wrapper]:text-white! focus-within:[&_.password-field-wrapper]:ring-fuchsia-500!"

    default color: :brand
  end

  customize :popover_kit do
    from :popover
    # @class lands on the OUTER wrapper (`<div class={@class}>`), but the component colours the
    # floating panel `[data-floating-content]` deep inside. Colour the panel only — an unscoped
    # bg-* would paint the full-width wrapper bar instead. The arrow uses bg-inherit, so it picks
    # up the fuchsia fill automatically.
    color :brand,
          "[&_[data-floating-content]]:bg-fuchsia-600! [&_[data-floating-content]]:text-white! [&_[data-floating-content]]:border-fuchsia-600!"

    default color: :brand,
            content_class: "bg-fuchsia-600! text-white! border-fuchsia-600!"
  end

  customize :progress_kit do
    from :progress
    # @class lands on the `.progress-section` fill bar itself, so colour it directly.
    color :brand, "bg-fuchsia-600! text-white!"
    default color: :brand
  end

  customize :radio_card_kit do
    from :radio_card

    color :brand,
          "[&_.radio-card-wrapper]:bg-fuchsia-600! [&_.radio-card-wrapper]:text-white! [&_.radio-card-wrapper]:has-[:checked]:bg-fuchsia-700! [&_.radio-card-input]:border-fuchsia-600! [&_.radio-card-input]:checked:accent-fuchsia-600!"

    default color: :brand
  end

  customize :radio_field_kit do
    from :radio_field

    color :brand,
          "text-fuchsia-600! [&_.radio-field-wrapper_.radio-input]:checked:accent-fuchsia-600! [&_.radio-field-wrapper_.radio-input]:border-fuchsia-600!"

    default color: :brand
  end

  customize :range_field_kit do
    from :range_field

    color :brand,
          "[&_.range-field::-webkit-slider-thumb]:bg-fuchsia-600! [&_.range-field::-moz-range-thumb]:bg-fuchsia-600! [&_.range-field::-moz-range-thumb]:border-fuchsia-600! [&_.range-field::-webkit-slider-runnable-track]:bg-fuchsia-200! [&_.range-field::-moz-range-track]:bg-fuchsia-200!"

    default color: :brand
  end

  customize :rating_kit do
    from :rating

    color :brand,
          "[&_.rated]:text-fuchsia-600! [&_.rating-button]:hover:text-fuchsia-500! [&_.rating-button:has(~.rating-button:hover)]:text-fuchsia-500!"

    default color: :brand
  end

  customize :search_field_kit do
    from :search_field

    color :brand,
          "[&_.search-field-wrapper]:bg-fuchsia-600! [&_.search-field-wrapper]:border-fuchsia-600! [&_.search-field-wrapper>input]:text-white! [&_.search-field-wrapper>input]:placeholder:text-white! [&_.search-field-wrapper_.search-icon]:text-white! focus-within:[&_.search-field-wrapper]:ring-fuchsia-500!"

    default color: :brand
  end

  customize :sidebar_kit do
    from :sidebar
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"
    default color: :brand
  end

  customize :skeleton_kit do
    from :skeleton
    color :brand, "bg-fuchsia-600!"
    default color: :brand
  end

  customize :speed_dial_kit do
    from :speed_dial
    color :brand, "[&_.speed-dial-base]:bg-fuchsia-600! [&_.speed-dial-base]:text-white!"
    default color: :brand
  end

  customize :spinner_kit do
    from :spinner
    color :brand, "text-fuchsia-600! [&>span]:bg-fuchsia-600! [&>svg]:stroke-fuchsia-600!"
    default color: :brand
  end

  customize :stat_kit do
    from :stat
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"
    default color: :brand
  end

  customize :stepper_kit do
    from :stepper

    color :brand,
          "[&_.stepper-step]:border-fuchsia-600! [&_.stepper-step]:text-fuchsia-600! [&_.stepper-current-step_.stepper-step]:border-fuchsia-600! [&_.stepper-current-step_.stepper-step]:text-fuchsia-600! [&_.stepper-completed-step_.stepper-step]:bg-fuchsia-600! [&_.stepper-completed-step_.stepper-step]:border-fuchsia-600! [&_.stepper-completed-step_.stepper-step]:text-white! [&_.stepper-separator]:border-fuchsia-500!"

    default color: :brand
  end

  customize :table_kit do
    from :table

    # @class lands on the `<table>` element itself (not the wrapper), so colour it
    # directly; td/th/divide scopes still target its descendants correctly.
    color :brand,
          "bg-fuchsia-600! text-white! border-fuchsia-600! [&_*]:divide-fuchsia-600! [&_td]:border-fuchsia-600! [&_th]:border-fuchsia-600!"

    default color: :brand
  end

  customize :table_content_kit do
    from :table_content
    color :brand, "bg-fuchsia-600! text-white! border-fuchsia-600!"
    default color: :brand
  end

  customize :tabs_kit do
    from :tabs

    color :brand,
          "[&_.tab-trigger.active-tab]:bg-fuchsia-600! [&_.tab-trigger.active-tab]:text-white! [&_.tab-trigger.active-tab]:border-fuchsia-600! [&_.tab-trigger]:hover:bg-fuchsia-500! [&_.tab-trigger]:hover:text-white! [&_.tab-trigger]:hover:border-fuchsia-500!"

    default color: :brand
  end

  customize :tel_field_kit do
    from :tel_field

    color :brand,
          "[&_.tel-field-wrapper]:bg-fuchsia-600! [&_.tel-field-wrapper]:border-fuchsia-600! [&_.tel-field-wrapper>input]:text-white! [&_.tel-field-wrapper>input]:placeholder:text-white! text-fuchsia-600!"

    default color: :brand
  end

  customize :text_field_kit do
    from :text_field

    color :brand,
          "[&_.text-field-wrapper]:bg-fuchsia-600! [&_.text-field-wrapper]:border-fuchsia-600! [&_.text-field-wrapper>input]:text-white! [&_.text-field-wrapper>input]:placeholder:text-white! focus-within:[&_.text-field-wrapper]:ring-fuchsia-500!"

    default color: :brand
  end

  customize :textarea_field_kit do
    from :textarea_field

    color :brand,
          "text-fuchsia-600! [&_.textarea-field-wrapper]:border-fuchsia-600! [&_.textarea-field-wrapper]:bg-fuchsia-50! focus-within:[&_.textarea-field-wrapper]:ring-fuchsia-500!"

    default color: :brand
  end

  customize :timeline_kit do
    from :timeline

    color :brand,
          "[&_.timeline-bullet]:bg-fuchsia-600! [&_.timeline-bullet]:text-white! [&_.timeline-vertical-line]:after:border-fuchsia-600! [&_.timeline-horizontal-line]:border-fuchsia-600!"

    default color: :brand
  end

  customize :toast_kit do
    from :toast
    color :brand, "bg-fuchsia-600! text-white!"
    default color: :brand
  end

  customize :toggle_field_kit do
    from :toggle_field

    color :brand,
          "[&_.toggle-field-base]:peer-checked:bg-fuchsia-600! [&_.toggle-field-base]:dark:peer-checked:bg-fuchsia-500!"

    default color: :brand
  end

  customize :tooltip_kit do
    from :tooltip

    # @class lands on the OUTER wrapper (`<div class={@class}>` / inline `<span>`), but the component
    # colours the floating panel `[data-floating-content]` only. Colour the panel — an unscoped bg-*
    # would paint the full-width wrapper bar instead (same trap as popover). The arrow uses
    # bg-inherit, so it inherits the fuchsia fill automatically.
    color :brand,
          "[&_[data-floating-content]]:bg-fuchsia-600! [&_[data-floating-content]]:text-white! [&_[data-floating-content]]:border-fuchsia-600!"

    default color: :brand,
            content_class: "bg-fuchsia-600! text-white! border-fuchsia-600!"
  end

  customize :url_field_kit do
    from :url_field

    color :brand,
          "[&_.url-field-wrapper]:border-fuchsia-600! [&_.url-field-wrapper]:bg-fuchsia-50! text-fuchsia-600! focus-within:[&_.url-field-wrapper]:ring-fuchsia-500!"

    default color: :brand
  end
end
