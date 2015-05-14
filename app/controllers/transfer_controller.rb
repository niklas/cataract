class TransferController < TorrentComponentController
  Fields = [:up_rate, :down_rate, :size_bytes, :completed_bytes, :active?]

  def index
    render json: collection, each_serializer: TransferSerializer, root: 'transfers'
  end

  def show
    render_json
  end

  def create
    torrent.start!
    flash[:notice] = I18n.t('flash.transfer.create.notice', name: torrent.title)
    render_json
  end

  def destroy
    torrent.stop!
    flash[:notice] = I18n.t('flash.transfer.destroy.notice', name: torrent.title)
    render json: [torrent], each_serializer: TorrentSerializer, root: 'torrents'
  end

  private
  def render_json
    resource.fetch! Fields
    render json: resource, serializer: TransferSerializer
  end

  def collection
    @transfers ||= torrents_for_collection.tap do  |torrents|
        authorize! :index, Torrent
        Torrent.remote.apply torrents, Fields
        torrents.reject { |t| t.transfer.active? }.each(&:finally_stop!)
      end.map(&:transfer)
  end

  def torrents_for_collection
    if parent?
      [parent]
    else
      Torrent.running_or_listed(params[:running])
    end
  end
end
