class TransferSerializer < BaseSerializer
  embed :ids, include: true
  include TorrentsHelper
  attributes :id,
             :torrent_id,
             :progress,
             :up_rate,
             :active,
             :eta,
             :info_hash,
             :down_rate

  def eta
    unless object.arrived?
      time_left_in_words object.left_seconds
    else
      ' '
    end
  end

  def id
    object.torrent_id # trick ember
  end

  def active
    !!object.active?
  end
end
