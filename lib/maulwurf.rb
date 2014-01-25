require 'mechanize'

class Maulwurf
  autoload :Directive     , 'maulwurf/directive'
  autoload :PageDirective , 'maulwurf/page_directive'
  autoload :FileDirective , 'maulwurf/file_directive'
  autoload :Command       , 'maulwurf/command'
  autoload :FollowCommand , 'maulwurf/follow_command'

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
      process_page page, found.right
    else
      raise "no directive found for #{page.uri}"
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

  # TODO check result to avoid having to raise Done
  def process_page(page, command)
    if command.respond_to?(:run)
      command.run page, nose
    elsif command.respond_to?(:each)
      # stop on the first command being successful
      command.find { |c| process_page page, c }
    elsif command.is_a?(Symbol)
      public_send command, page, nose
    else
      command.call page, nose
    end
  end

  def find_directive(page)
    uri = page.uri.to_s
    debug { "finding directive for #{uri}" }
    self.class.directives.find do |directive|
      # OPTIMIZE full routing on uri
      directive.responsible_for? uri, page
    end
  end

  def debug
    STDERR.puts yield
  end

end
