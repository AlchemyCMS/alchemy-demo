require "test_helper"
require "view_component/test_helpers"

class Alchemy::Ingredients::EventViewTest < ViewComponent::TestCase
  test "renders the referenced event's name and location" do
    event = Event.create!(
      name: "Test Summit",
      starts_at: Time.utc(2026, 9, 1, 10),
      ends_at: Time.utc(2026, 9, 1, 12),
      location: Location.new(name: "Berlin")
    )
    ingredient = Alchemy::Ingredients::Event.new(related_object: event)

    result = render_inline(Alchemy::Ingredients::EventView.new(ingredient))

    assert_includes result.text, "Test Summit"
    assert_includes result.text, "Berlin"
  end

  test "does not render without an event" do
    ingredient = Alchemy::Ingredients::Event.new
    refute Alchemy::Ingredients::EventView.new(ingredient).render?
  end
end
