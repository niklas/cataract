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
      dig nose.page
    end
  rescue Done
    # yeah.. FIXME
    return true
  end

  def dig(page)
    if found = find_directive(page)
      process_page found.right, page
    else
      raise "no directive found for #{page.uri}"
    end
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

  def process_page(command, page)
    if command.respond_to?(:run)
      command.run page, nose
    elsif command.is_a?(Symbol)
      public_send command, page, nose
    else
      command.call page, nose
    end
  end

  def find_directive(page)
    uri = page.uri.to_s
    self.class.directives.find do |directive|
      # OPTIMIZE full routing on uri
      directive.responsible_for? uri, page
    end
  end

end
