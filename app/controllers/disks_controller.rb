class DisksController < InheritedResources::Base
  load_and_authorize_resource
  layout 'library'

  respond_to :js, :html

  def new
    resource.valid?
    new!
  end

  def create
    create! { disk_path(@disk) }
  end
end
