Rails.application.config.to_prepare do
  Alchemy.register_ability Ability
end
