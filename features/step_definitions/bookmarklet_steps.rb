When /^I use the scraping bookmarklet on (.+)$/ do |page_name|
  location = path_to(page_name)
  visit '/404'

  x = "blobby"
  x.extend BookmarkletHelper

  page.execute_script <<-EOJS
    document.test_location = '#{location}';
    #{x.script_for_bookmarklet(new_scraping_url(format: 'js'))}
  EOJS
end
