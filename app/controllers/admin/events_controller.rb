class Admin::EventsController < Alchemy::Admin::ResourcesController
  add_alchemy_filter :for_timeframe, type: :select, options: %w[upcoming past all]
end
