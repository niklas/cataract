class TransferController < InheritedResources::Base
  belongs_to :torrent, :singleton => true

  respond_to :js, :html

  def create
    torrent.start!
    respond_with torrent
  end

  def destroy
    torrent.stop!
    respond_with torrent
  end

  private

  def torrent
    parent
  end
end