module Alchemy
  module Ingredients
    class EventView < BaseView
      delegate :event, to: :ingredient

      def call
        helpers.render(partial: "alchemy/events/event", locals: {event: event})
      end

      def render?
        !!event
      end
    end
  end
end
