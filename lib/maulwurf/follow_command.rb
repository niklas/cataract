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

  def run(maulwurf, agent)
    page = agent.page
    links = page.search @options.fetch(:css) { 'a' }
    if links.length == 1
      follow links.first, agent, maulwurf
    end
    if @text.empty?
      if title = @options[:title]
        links = links.select {|l| title === l[:title] }
      end
      unless links.empty?
        follow links.first, agent, maulwurf
      else
        false
      end
    else
      if link = page.link_with( @options.merge(text: /#{@text}/) )
        follow link, agent, maulwurf
      else
        false
      end
    end
  end

  private

  def follow(link, agent, maulwurf)
    if @text.blank?
      maulwurf.log "following #{@options.inspect}"
    else
      maulwurf.log "following '#{@text}'"
    end
    agent.click link
  end
end
