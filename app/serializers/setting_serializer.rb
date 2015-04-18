require_dependency 'base_serializer'
class SettingSerializer < BaseSerializer
  include ActionView::Helpers::TagHelper
  include BookmarkletHelper
  attributes :disable_signup,
             :id,
             :bookmark_link
  has_one :incoming_directory, embed: :ids, include: false

  def id
    'all'
  end

  def bookmark_link
    link_to_scrape_bookmarklet "Bookmarklet", class: 'label label-primary', url: object.scraping_url
  end
end
