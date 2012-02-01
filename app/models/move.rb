class Move < ActiveRecord::Base

  include Queueable

  attr_accessible :target_id

  belongs_to :torrent
  belongs_to :target, :class_name => 'Directory'

  validates_numericality_of :torrent_id
  validates_numericality_of :target_id

  # FileUtils will use cp+rm between file system boundaries. consider using rsync for robustness and progress
  def work
    FileUtils.mv torrent.content.path, target.path
    if torrent.content.multiple?
      FileUtils.rmdir File.dirname(torrent.content.files.first)
    end
    torrent.content_directory = target
    torrent.save!
  end

end

