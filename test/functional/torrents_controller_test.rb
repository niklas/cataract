require File.dirname(__FILE__) + '/../test_helper'
require 'torrents_controller'

# Re-raise errors caught by the controller.
class TorrentsController; def rescue_action(e) raise e end; end

class TorrentsControllerTest < Test::Unit::TestCase
  def setup
    @controller = TorrentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
