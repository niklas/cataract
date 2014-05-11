# Load the rails application
require File.expand_path('../application', __FILE__)

# as early as possible (database.yml)
SafeYAML::OPTIONS[:default_mode] = :safe

# Initialize the rails application
Cataract::Application.initialize!
