require_dependency 'base_serializer'
class SettingSerializer < BaseSerializer
  include ActionView::Helpers::TagHelper
  include BookmarkletHelper
  attributes :disable_signup
  has_one :incoming_directory, embed: :ids, include: false

  def attributes
    super.tap do |hash|
      hash['id'] = 'all'
      hash['bookmark_link'] = link_to_scrape_bookmarklet "Bookmarklet", class: 'label label-primary', url: object.scraping_url
    end
  end
end
