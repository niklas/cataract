require 'mechanize'

class Maulwurf
  autoload :Directive, 'maulwurf/directive'
  autoload :Command, 'maulwurf/command'
  autoload :FollowCommand, 'maulwurf/follow_command'

  class_attribute :directives

  class Done < Exception; end

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
  rescue Done
    # yeah.. FIXME
    return true
  end


  class PageDirective < Directive
  end

  class FileDirective < Directive
    # ignoring given (left) mime tipe
    def responsible_for?(uri, page)
      page.is_a? Mechanize::File
    end
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
      directive.responsible_for? uri.to_s, page
    end

    if found
      if found.right.respond_to?(:run)
        found.right.run page, nose
      elsif found.right.is_a?(Symbol)
        public_send found.right, page, nose
      else
        found.right.call page, nose
      end
    else
      raise "no directive found for #{uri}"
    end
  end

end
