class Event < ActiveRecord::Base
  # Alchemy's admin resource index searches and sorts via Ransack, which requires
  # its attributes, relations and scopes to be allowlisted. SearchableResource
  # derives those from the columns and +alchemy_resource_relations+.
  # NOTE: the `alchemy:module` generator should add this to the model it generates.
  extend Alchemy::SearchableResource

  belongs_to :location, optional: true

  validates :name, presence: true

  scope :upcoming, -> { where(arel_table[:ends_at].gteq(Time.current)).order(:starts_at) }
  scope :past, -> { where(arel_table[:ends_at].lt(Time.current)).order(starts_at: :desc) }

  # Resolves the timeframe stored by the events_overview element's Select
  # ingredient to a matching relation. Also exposed as an admin filter, so it is
  # a scope (Ransack invokes it) and allowlisted in +ransackable_scopes+.
  scope :for_timeframe, ->(timeframe) {
    case timeframe.to_s
    when "past" then past
    when "all" then reorder(:starts_at)
    else upcoming
    end
  }

  # Show and edit the location relation as location#name in the admin resource.
  def self.alchemy_resource_relations
    {location: {attr_method: "name", attr_type: "string"}}
  end

  def self.ransackable_scopes(_auth_object = nil)
    %i[for_timeframe]
  end

  def date_range
    return "" unless starts_at

    if ends_at && ends_at.to_date != starts_at.to_date
      "#{starts_at.strftime("%b %-d")} – #{ends_at.strftime("%b %-d, %Y")}"
    else
      starts_at.strftime("%B %-d, %Y")
    end
  end
end
