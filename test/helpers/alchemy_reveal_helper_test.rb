require "test_helper"

class AlchemyRevealHelperTest < ActionView::TestCase
  include AlchemyRevealHelper

  # Minimal doubles standing in for Alchemy::Element / Alchemy::Ingredient so the
  # helper's introspection is unit-tested without touching the database.
  Ingredient = Struct.new(:role, :type)
  FakeElement = Struct.new(:name, :ingredients, :nested_elements)

  test "element_source summarizes name, ingredient roles/types and nested names" do
    element = FakeElement.new(
      "image_text",
      [Ingredient.new("headline", "Alchemy::Ingredients::Text"),
       Ingredient.new("image", "Alchemy::Ingredients::Picture")],
      [FakeElement.new("gallery_image", [], [])]
    )

    result = element_source(element)

    assert_equal "image_text", result[:name]
    assert_equal [["headline", "Text"], ["image", "Picture"]], result[:ingredients]
    assert_equal ["gallery_image"], result[:nested]
  end
end
