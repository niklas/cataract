class JavascriptsController < ApplicationController
  layout false
  skip_before_filter :login_required
  def dynamic_content_dirs
    @dirs = Directory.all.select(&:show_sub_dirs?)
  end
end
