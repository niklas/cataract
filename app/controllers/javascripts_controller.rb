class JavascriptsController < ApplicationController
  def dynamic_content_dirs
    @dirs = Directory.all.select(&:show_sub_dirs?)
  end
end
