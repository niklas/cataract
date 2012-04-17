class Move < ActiveRecord::Base

  include Queueable

  attr_accessible :target_id

  belongs_to :torrent
  belongs_to :target, :class_name => 'Directory'

  validates_numericality_of :torrent_id
  validates_numericality_of :target_id

  # FileUtils will use cp+rm between file system boundaries. consider using rsync for robustness and progress
  def work
    torrent.stop
    FileUtils.mv torrent.content.path, target.path
    if torrent.content.multiple?
      FileUtils.rmdir File.dirname(torrent.content.files.first)
    end
    torrent.content_directory = target
    torrent.save!
  end

  def auto_target!
    if torrent
      sorted = Directory.all.sort_by { |directory| score_for(torrent, directory) }
      self.target = sorted.first
    end
  end

  private
  def score_for(torrent, directory)
    score = 0

    dn = directory.name.downcase
    dp = directory.path.basename.to_s.downcase
    tt = torrent.title.downcase
    score += diff(dn, tt)
    score += diff(dp, tt)
    score += diff(tt, dn)
    score += diff(tt, dp)
    if fn = torrent.filename
      score += diff(fn, dn)
      score += diff(fn, dp)
    end
    score
  end

  def diff(a,b)
    Levenshtein.distance(a,b)
  end

end

