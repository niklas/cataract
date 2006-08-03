class Notifier < ActionMessenger::Base
  def finished(user,torrent)
    message.to = user.kind_of?(User) ? user.jabber : user
    message.subject = "Torrent finished"
    message.body = "'#{torrent.short_title}' is finished."
  end

  def test(user)
    message.to = user.jabber
    message.subject = "Test Message"
    message.body = "Welcome #{user.login}!"
  end

  def new(user,torrent)
    message.to = user.kind_of?(User) ? user.jabber : user
    message.subject = "new Torrent"
    message.body = "'#{torrent.short_title}' was added and will be downloaded."
  end
end
