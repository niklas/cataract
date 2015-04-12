class FeedsController < InheritedResources::Base
  load_and_authorize_resource except: [:index]
  respond_to :json

  protected
  def collection
    authorize! :index, Feed
    @feeds ||= end_of_association_chain.order('title')
  end
end
