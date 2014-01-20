class Maulwurf::FollowCommand < Maulwurf::Command
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
