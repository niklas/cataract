require 'mechanize'

class Maulwurf
  autoload :Directive, 'maulwurf/directive'
  autoload :Command, 'maulwurf/command'
  autoload :FollowCommand, 'maulwurf/follow_command'

  class_attribute :directives

  def self.follow(*a)
    FollowCommand.new(*a)
  end

  def self.page direction
    directives << PageDirective.new(direction)
  end

  def self.file(*a)
    directives << FileDirective.new(*a)
  end

  def process(start_url)
    nose.get start_url
    while true do
      dig
    end
  end


  class PageDirective < Directive
  end

  class FileDirective < Directive
  end

  private

  def self.inherited(child)
    super
    child.directives = []
  end

  def nose
    @nose ||= Mechanize.new.tap do |agent|
      agent.user_agent_alias = 'Mac Safari'
    end
  end

  def dig
    page = nose.page
    uri = page.uri
    found = self.class.directives.find do |directive|
      # OPTIMIZE full routing on uri
      directive.responsible_for? uri.to_s
    end

    if found
      found.go page, nose
    else
      raise "no directive found for #{uri}"
    end
  end

end
