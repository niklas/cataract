class LogEntriesController < ApplicationController
  def index
    @log_entries = LogEntry.after(params[:last]).all
    respond_to do |wants|
      wants.js
      wants.html
    end
  end
end
