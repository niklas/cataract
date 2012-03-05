class MoveController < InheritedResources::Base
  belongs_to :torrent, :singleton => true

  respond_to :html, :js

  def create
    create! { parent_url }
  end

  private

  def interpolation_options
    { torrent: parent.title, target: resource.target.name }
  end
end
