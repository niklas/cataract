class Move < ActiveRecord::Base

  include Queueable

  attr_accessible :target_disk_id,
                  :target_directory_id,
                  :title,
                  :torrent_id

  belongs_to :torrent
  belongs_to :target_directory, :class_name => 'Directory'
  belongs_to :target_disk, :class_name => 'Disk'

  alias_method :directory, :target_directory
  alias_method :disk     , :target_disk

  validates_numericality_of :torrent_id
  validates_numericality_of :target_directory_id

  def self.recent
    order('created_at DESC')
  end

  # FileUtils will use cp+rm between file system boundaries. consider using rsync for robustness and progress
  def work
    torrent.stop
    payload = torrent.payload
    FileUtils.mv payload.path, final_directory.full_path
    if payload.multiple?
      FileUtils.rmdir File.dirname(payload.files.first)
    end
    torrent.content_directory = final_directory
    torrent.save!
  end

  def auto_target!
    if torrent
      sorted = Directory.all.sort_by { |directory| score_for(torrent, directory) }
      self.target_directory = sorted.first
    end
    if target_directory
      self.target_disk ||= target_directory.disk
    end
  end

  def target_name
    [target_disk, target_directory].compact.map(&:name).join(' / ')
  end

  def final_directory
    @final_directory ||= find_final_directory
  end

  def title=(title_from_ember)
  end

  def title
    I18n.translate('flash.move.create.notice', torrent: torrent.title, target: target_name)
  end

  private
  def score_for(torrent, directory)
    score = 0

    dn = directory.name.downcase
    dp = directory.relative_path.basename.to_s.downcase
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
    Levenshtein.distance(a,b) - ( a.include?(b) ? b.length * 2 : 0)
  end

  def find_final_directory
    if directory && disk
      Directory.find_or_create_by_directory_and_disk(directory, disk)
    elsif directory
      Directory.find_or_create_by_directory_and_disk(directory, source.disk)
    elsif disk
      Directory.find_or_create_by_directory_and_disk(source, disk)
    else
      raise "no target given at all"
    end
  end

  def source
    torrent.content_directory
  end

end

