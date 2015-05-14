class Torrent
  class NotRunning < ActiveRecord::RecordInvalid; end

  temporary_predicate :start_automatically
  after_save :start!, :if => :start_automatically?

  def method_missing_with_xml_rpc(meth, *args, &blk)
    if remote.respond_to?(meth)
      remote.public_send meth, self, *args, &blk
    else
      method_missing_without_xml_rpc meth, *args, &blk
    end
  rescue NotRunning => e
    finally_stop! unless archived?
    raise e
  rescue HasNoInfoHash => e
    finally_stop!
    return
  end
  #alias_method_chain :method_missing, :xml_rpc

  def self.remote
    @remote ||= Cataract::TransferAdapters::RTorrentAdapter.new rtorrent_socket_path
  end

  def self.reset_remote!
    @remote = nil
  end

  def transfer
    @transfer ||= Cataract::Transfer.new torrent_id: id, info_hash: info_hash
  end

  def remote
    self.class.remote
  end

  def self.rtorrent_socket_path
    Rails.root/'tmp'/'rtorrent.socket'
  end

  # rTorrent deletes the torrent file if removing a tied torrent, so we will
  # only add a copy of our torrent to rtorrent. For this we will use
  # #session_path
  def session_path
    path.to_path + '.running'
  end

  def load!
    FileUtils.cp path, session_path
    remote.load! session_path
    remote.set_directory self, content_directory.full_path
  end
end
