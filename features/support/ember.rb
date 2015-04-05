# You need some sort of indication that an Ajax transaction exists. jQuery.active doesn't seem to do the
# trick, so we use the following JS (well, we use CoffeeScript, but whatever) that gets inserted into 
# our application. 
#
#$(function() {
#  var body, doc;
#  body = $('body');
#  doc = $(document);
#  doc.ajaxStart(function() {
#    return body.addClass('ajax-in-progress').removeClass('ajax-quiet');
#  });
#  return doc.ajaxStop(function() {
#    return body.addClass('ajax-quiet').removeClass('ajax-in-progress');
#  });
#});
#
# You can see below, in wait_for_ember_run_loop_to_complete, that we call: 
# jQuery('body').hasClass('ajax-quiet')
 
module EmberHelpers
  # Chill out until Ember is ready to go. First we wait for the page to load, because redirects
  # (e.g. Doorkeeper) can confuse things. Once the page is loaded, we check that it's
  # an Ember app (.ember-application), and that .application-ready class (from Shared.LoadingRouteMixin) is
  # present.
  def wait_for_ember_application_to_load
    # Now, patiently wait for the .ember-application class to make sure we're in an ember app,
    # and .application-ready to verify that it's ready to respond to requests.
    using_wait_time 20 do
      patiently do
        find ".ember-application"
      end
    end

    # So now the application is ready but there might be something in the run loop. Chill
    # and wait for that to finish.
    wait_for_ember_run_loop_to_complete
  end

  # This runs after every step in a tagged scenario, or whenver
  # we need to specifically make sure that Ember is done with whatever
  # it is working on.
  def wait_for_ember_run_loop_to_complete
    # At this point the page should be loaded, so if we don't see .ember-application,
    # we assume it's not an Ember app and this method can just return because there's nothing
    # to wait for. Since this is used in tagged scenarios, there might be pages in the scenario
    # that aren't Ember-fied (e.g. Doorkeeper's pages). We don't want to fail; we just want to fall
    # through.
    patiently do
      return unless page.has_css? '.ember-application'
    end

    # And here is where the magic happens. We check that Ember is instantiated, that there are no
    # scheduled timers, and that there is no current run loop. This is the way that Ember does it
    # internally, so hey, if it's good enough for production, it's good enough for testing.
    2000.times do #this means up to 20 seconds
      return if page.evaluate_script "'undefined' == typeof window.jQuery"
      return if page.evaluate_script "$('body').hasClass('ajax-quiet') && (typeof Ember === 'object') && !Ember.run.hasScheduledTimers() && !Ember.run.currentRunLoop"
      sleep 0.01
    end
  end
end

World EmberHelpers

AfterStep('@ember-fuckery') do
  wait_for_ember_run_loop_to_complete
end

Then(/^I should be in an Ember app$/) do
  wait_for_ember_application_to_load
  wait_for_ember_run_loop_to_complete
end
