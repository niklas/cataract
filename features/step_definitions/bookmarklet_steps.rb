When /^I use the scraping bookmarklet$/ do
  page.execute_script RailsBookmarklet::compile_invocation_script(new_scraping_path)
end
