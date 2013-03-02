class DisksController < InheritedResources::Base
  load_and_authorize_resource except: [:index]
  respond_to :json

  protected
  def collection
    authorize! :index, Disk
    @disks ||= end_of_association_chain.order('name')
  end
end
