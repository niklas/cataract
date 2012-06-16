class DirectoriesController < InheritedResources::Base
  belongs_to :disk, optional: true
  respond_to :js, :html

  load_and_authorize_resource

  def create
    create! { redirect_path }
  end

  def update
    update! { redirect_path }
  end

  private
  def interpolation_options
    { name: resource.name }
  end

  def redirect_path
    if resource.is_root?
      directories_path
    else
      directory_path(resource.parent)
    end
  end
end
