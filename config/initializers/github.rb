Cataract::Application.class_eval do
  mattr_accessor :current_commit
  self.current_commit = ENV['CURRENT_COMMIT'].presence || `git log -1 HEAD --format=format:%H`.chomp

  if Rails.env.test?
    self.current_commit = "5355114daa895b1732b44f70931e205260d57731"
  end

  Rails.logger.info "COMMIT: #{current_commit}"
end
