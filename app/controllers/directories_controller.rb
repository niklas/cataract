class DirectoriesController < InheritedResources::Base
  respond_to :js, :html

  load_and_authorize_resource

  def create
    create! { directories_path }
  end

  private
  def interpolation_options
    { name: resource.name }
  end
end
