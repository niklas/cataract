Rails.configuration.after_initialize do
  InheritedResources.flash_keys = [:notice, :alert]
  EmberRailsFlash.enable_flash_responder 'json'
end

