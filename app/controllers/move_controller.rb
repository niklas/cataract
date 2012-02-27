class MoveController < InheritedResources::Base
  belongs_to :torrent, :singleton => true

  def create
    create! { parent_url }
  end
end
