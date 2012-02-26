# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def group_link(status)
    content_tag('li',
                link_to(status.capitalize, :controller => 'torrents', :action => 'list', :status => status),
                { :class => (@status == status ? 'active' : '')}
    )
  end

  def all_stylesheets
    %w(layout style watchlist torrents forms corners).map do |style|
      stylesheet_link_tag style
    end
  end

  def context
    page.instance_variable_get("@context").instance_variable_get("@template")
  end

  def nice_date(d,fallback='unknown')
    d ? d.to_s(:db) : content_tag(:span,fallback, :class => 'warning')
  end

  def number_to_human_rate(num=nil,precision=1)
    size = number_to_human_size(num,precision)
    size ? "#{size}/s" : size
  end

  # Translate mock
  def _ string
    string
  end

  def torrent_list_id(search=@search)
    "#{search.status}_torrents"
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
