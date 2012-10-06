class DisksController < InheritedResources::Base
  load_and_authorize_resource
  respond_to :json
end
