class MoveController < InheritedResources::Base
  belongs_to :torrent, :singleton => true
end
