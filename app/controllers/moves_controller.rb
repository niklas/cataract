class MovesController < InheritedResources::Base
  belongs_to :torrent

  private

  def build_resource
    @move ||= Move.new resource_params.first.merge(:torrent_id => parent.id)
  end
end
