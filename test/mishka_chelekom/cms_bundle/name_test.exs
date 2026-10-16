defmodule MishkaChelekom.CmsBundle.NameTest do
  use ExUnit.Case, async: true

  alias MishkaChelekom.CmsBundle.Name

  doctest Name

  test "a stored name is lowercase with single hyphens, whatever separated the parts" do
    assert Name.stored("Chelekom__Headless - Tree_Select") == "chelekom-headless-tree-select"
    assert Name.stored("-chelekom-theme-") == "chelekom-theme"
    assert Name.stored(:button_link) == "button-link"
  end

  test "a name already stored is left as it is" do
    for name <- ~w(chelekom-button chelekom-headless-button-content chelekom-theme) do
      assert Name.stored(name) == name
    end
  end

  test "a kit with no name prefixes nothing" do
    assert Name.component("", "button_content") == "button-content"
    assert Name.component(nil, "icon") == "icon"
  end
end
