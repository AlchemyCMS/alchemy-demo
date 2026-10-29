module Alchemy
  module Ingredients
    # A custom ingredient type. Its value is a reference to an app `Event`
    # record managed in the custom Events admin module, stored through the
    # polymorphic `related_object` association.
    class Event < Alchemy::Ingredient
      related_object_alias :event, class_name: "Event"

      def preview_text(maxlength = 30)
        event&.name.to_s[0...maxlength]
      end
    end
  end
end
