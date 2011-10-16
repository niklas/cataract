# http://stackoverflow.com/questions/4657145/migrating-from-restful-authentication-to-devise
require "digest/sha1"  

module Devise
  module Encryptors
    class OldRestfulAuthentication < Base
      def self.digest(password, stretches, salt, pepper)
        Digest::SHA1.hexdigest("--#{salt}--#{password}--")
      end
    end
  end
end
