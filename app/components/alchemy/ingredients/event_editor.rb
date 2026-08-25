module Alchemy
  module Ingredients
    class EventEditor < BaseEditor
      delegate :event, to: :ingredient

      def input_field
        tag.div(class: "input-field") do
          select_tag(
            form_field_name(:event_id),
            options_from_collection_for_select(::Event.order(:starts_at), :id, :name, event&.id),
            id: form_field_id(:event_id),
            class: "full_width",
            include_blank: true
          )
        end
      end
    end
  end
end
