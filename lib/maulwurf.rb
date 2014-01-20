require 'mechanize'

class Maulwurf
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
    found = self.class.directives.find do |directive|
      directive.responsible_for? start_url
    end
    if found
      page = nose.get start_url
      found.go page
      binding.pry
    end
  end

  class Command
  end

  class FollowCommand < Command
    def initialize(link_name, options={})
      @link_name = link_name
      @options = options
    end

    def run(page)
      if link = page.link_with( @options.merge(text: /#{@link_name}/) )
        link.click
      else
        raise 'cannot find link'
      end
    end
  end

  class Directive
    attr_reader :left
    attr_reader :right
    def initialize directions
      @left = directions.keys.first
      @right = directions.values.first
    end

    def responsible_for? something
      @left === something
    end

    def go(*a)
      @right.run(*a)
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

end
