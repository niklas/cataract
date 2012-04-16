class MoveController < InheritedResources::Base
  belongs_to :torrent, :singleton => true

  respond_to :js, :html

  private

  def interpolation_options
    { torrent: parent.title, target: resource.target.name }
  end
end
