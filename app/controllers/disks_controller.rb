class DisksController < InheritedResources::Base
  load_and_authorize_resource

  respond_to :js

  def new
    resource.valid?
    new!
  end

  def create
    create! { disk_directories_path(@disk) }
  end
end
