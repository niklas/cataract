module JqueryMobile::Capybara
  # Examples of waiting for a page loading to show and hide in jQuery Mobile.

  def wait_for_loading
    wait_until { page.has_css?('html.ui-loading') }
  rescue Capybara::TimeoutError
  end

  def wait_for_loaded
    wait_until { page.has_no_css?('html.ui-loading') }
  rescue Capybara::TimeoutError
    flunk "Failed at waiting for loading to complete."
  end

  def wait_for_page_load
    wait_for_loading && wait_for_loaded
  end
end

World(JqueryMobile::Capybara)
