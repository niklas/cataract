class Maulwurf::FollowCommand < Maulwurf::Command
  def initialize(text = '', options={})
    if text.is_a?(Hash) # extract_options
      @text = ''
      @options = text
    else
      @text = text
      @options = options
    end
  end

  def run(page, agent)
    if @text.empty?
      links = page.search @options.fetch(:css) { 'a' }
      if title = @options.fetch(:title)
        links = links.select {|l| l[:title] == title }
      end
      unless links.empty?
        agent.click links.first
      else
        raise "cannot find link #{@options.inspect}"
      end
    else
      if link = page.link_with( @options.merge(text: /#{@text}/) )
        link.click
      else
        raise "cannot find link with text: #{@text} (#{@options.inspect})"
      end
    end
  end
end
