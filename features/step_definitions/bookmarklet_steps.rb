When /^I use the scraping bookmarklet on (.+)$/ do |page_name|
  location = path_to(page_name)
  visit '/404'

  page.execute_script <<-EOJS
    document.test_location = '#{location}';
    #{RailsBookmarklet::compile_invocation_script(new_scraping_path)}
  EOJS
end
