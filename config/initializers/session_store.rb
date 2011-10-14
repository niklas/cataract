# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_cataract_session',
  :secret      => 'f2e32bd1b37a98f1c30ab2dff8fe68c8c414f8c2b0765c9e38f5a0f9c88a4ade0773e61aa1143b7cc2d891080a8e91f5abd26259fbad5ca85e8df77951a35f39'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
