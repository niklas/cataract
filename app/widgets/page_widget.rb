class PageWidget < JqueryMobile::Widget
  def display(options)
    @options = options.with_indifferent_access
    setup
    render
  end

  private
  def setup
    @widgets = @options.delete('widgets')
  end
end


#= for_header :fixed => true, :theme => 'e' do
#  = render_widget :torrents_header
#= render_widget :torrents
#
#= for_footer 'data-id' => 'torrents-navigation', :fixed => true do
#  = render_widget :torrents_navigation
