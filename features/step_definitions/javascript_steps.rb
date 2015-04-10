When /^I scroll to the bottom$/ do
  page.execute_script <<-EOJS
    $(window).scrollTop( $(document).height() )
  EOJS
  step %Q~I wait for the spinner to stop~
end

When /^the tick interval is reached$/ do
  sel = 'nav .status'
  page.should have_css(sel), 'need a button or something to click on to generate a tick'
  page.find(sel).click
  some_time_passes
end

When /^I confirm popup$/ do
  page.driver.browser.switch_to.alert.accept
end

When /^I drop file "(.*?)" onto (.*)$/ do |path, target_name|
  selector = selector_for(target_name)
  page.should have_css(selector)
  id = "drop#{Time.zone.now.to_i}"

  page.execute_script <<-EOJS
    window._drop_file_upload = $('<input />')
      .attr('id', '#{id}')
      .attr('type', 'file')
      .css({ position: 'absolute', zIndex: 9001, top: 0, right: 0})
      .appendTo('body');
  EOJS

  attach_file(id, File.expand_path(path))

  page.execute_script <<-EOJS
    $('#{selector}').trigger(
      $.Event("drop", {
        dataTransfer: {
          files: $('##{id}').hide()[0].files
        }
      })
    );
  EOJS
end

When /^I drag a file over (.*)$/ do |target_name|
  selector = selector_for(target_name)
  page.should have_css(selector)

  page.execute_script <<-EOJS
    $('#{selector}').trigger("dragover");
  EOJS
end

