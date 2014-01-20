class Maulwurf::Directive
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
