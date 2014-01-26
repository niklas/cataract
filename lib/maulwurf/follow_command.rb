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
    links = page.search @options.fetch(:css) { 'a' }
    if links.length == 1
      agent.click links.first
    end
    if @text.empty?
      if title = @options[:title]
        links = links.select {|l| l[:title] == title }
      end
      unless links.empty?
        agent.click links.first
      else
        false
      end
    else
      if link = page.link_with( @options.merge(text: /#{@text}/) )
        link.click
      else
        false
      end
    end
  end
end
