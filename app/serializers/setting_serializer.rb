class SettingSerializer < BaseSerializer
  include ActionView::Helpers::TagHelper
  include BookmarkletHelper
  attributes :disable_signup
  has_one :incoming_directory

  def attributes
    super.tap do |hash|
      hash['id'] = 'all'
      hash['bookmark_link'] = link_to_scrape_bookmarklet "Bookmarklet", class: 'label'
    end
  end
end
