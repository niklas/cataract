class Maulwurf
  class_attribute :directives

  def self.follow(*a)
    FollowCommand.new(*a)
  end

  def self.page direction
    directives << direction
  end

  def process(start_url)

  end

  class Command
  end

  class FollowCommand < Command
    def initialize(link_name)

    end
  end

  private

  def self.inherited(child)
    super
    child.directives = []
  end

end
