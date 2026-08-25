require "test_helper"

class EventTest < ActiveSupport::TestCase
  test "requires a name" do
    refute Event.new.valid?
    assert Event.new(name: "Kickoff").valid?
  end

  test "for_timeframe splits past and upcoming by ends_at" do
    past = Event.create!(name: "Past", starts_at: 2.months.ago, ends_at: 1.month.ago)
    upcoming = Event.create!(name: "Upcoming", starts_at: 1.month.from_now, ends_at: 2.months.from_now)

    assert_includes Event.for_timeframe("past"), past
    refute_includes Event.for_timeframe("past"), upcoming

    assert_includes Event.for_timeframe("upcoming"), upcoming
    refute_includes Event.for_timeframe("upcoming"), past

    all = Event.for_timeframe("all")
    assert_includes all, past
    assert_includes all, upcoming
  end
end
