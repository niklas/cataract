# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def settings
    @settings ||= Setting.singleton
  end

  def link_to_modal(link, url, opts={})
    link_to link, url, opts.merge(data: {toggle: 'modal', target: '#modal'}, remote: true)
  end

  module PartialHelper
    def replace_partial(partial, options = {})
      html = render(partial, options)
      if dom = Nokogiri.parse( html ).children.first['id']
        self[dom].replace_with(html)
        self[dom].trigger('create')
      else
        raise 'element not found'
      end
    end

    def append_to_list(searches = {})
      searches.each do |id, search|
        self[id].append(render(:partial => 'item', :collection => search.results))
      end
    end

    def update_list(searches = {})
      searches.each do |id, search|
        self[id].data({
          'url'       => torrents_path(search),
          'page'      => search.page || 1,
          'num-pages' => search.results.num_pages
        })
        self[id].html ''
      end
      append_to_list searches
    end
  end

  VersatileRJS::Page.class_eval do
    include PartialHelper
  end
end
