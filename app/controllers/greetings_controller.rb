class GreetingsController < ApplicationController
  before_action :clear_flash
  layout 'library'

  private

  def clear_flash
    flash.clear
  end
end
