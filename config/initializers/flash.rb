Rails.configuration.after_initialize do
  InheritedResources.flash_keys = [:notice, :alert]
end

