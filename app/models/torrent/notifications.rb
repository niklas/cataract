class Torrent
  before_update :notify_if_just_finished
  after_create :notify_users_and_add_it
  # checks is the torrent was just finished downloading 
  # and notifies all subscripted users if this is the case
  def notify_if_just_finished
    return # disabled for now
    if percent_done == 100
      old = Torrent.find(self.id)
      if old.percent_done < 100 and statusmsg == 'seeding'
        self.watchings.find_all_by_apprise(true).collect {|w| w.user }.each do |user| 
          Notifier.send_finished(user,self) if user.notifiable_via_jabber?
        end
      end
    end
  end

  # notifies the users that have +notify_on_new_torrents+ set and adds it to their watchlist
  def notify_users_and_add_it
    return # disabled for now
    return true if remote?
    User.find_all_by_notify_on_new_torrents(true).each do |user|
      Notifier.send_new(user,self) if user.notifiable_via_jabber?
      user.watch(self) unless user.dont_watch_new_torrents?
    end
  end

end
