# Registers the custom Events resource as an Alchemy admin module so it appears
# in the admin main navigation. The controller lives in the host app (not the
# engine), so no engine_name is given.
Rails.application.config.to_prepare do
  Alchemy::Modules.register_module(
    name: "events",
    navigation: {
      name: "modules.events",
      controller: "/admin/events",
      action: "index",
      icon: "calendar",
      sub_navigation: [{
        name: "modules.events",
        controller: "/admin/events",
        action: "index"
      }]
    }
  )
end
