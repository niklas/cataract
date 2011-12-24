require 'digest/sha1'

class User < ActiveRecord::Base
  # FIXME athentication
  #include Authentication
  #include Authentication::ByPassword
  #include Authentication::ByCookieToken
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  validates_length_of       :name,     :maximum => 100
  validates_length_of       :jabber, :on => :update,   :within => 3..100, :allow_nil => true

  has_many :watchings, :dependent => :destroy
  has_many :torrents, :through => :watchings

  has_many :comments

  # FIXME wtf
  # model_stamper
  

  attr_accessible :login, :email, :name, :password, :password_confirmation, :jabber, :notify_via_jabber

  def notifiable_via_jabber?
    notify_via_jabber? and jabber.present?
  end

  def watch(torrent)
    return if is_watching?(torrent)
    if self.watchings.create(:torrent => torrent, :apprise => true)
      torrent.log('is now watched', :info, self)
    end
  end

  def unwatch(torrent)
    w = self.watchings.find_by_torrent_id(torrent.id)
    if w
      w.destroy 
      torrent.log('is not watched anymore', :info, self)
    end
  end

  def is_watching?(torrent)
    watchings.find_by_torrent_id(torrent.id)
  end
  alias_method :watches?, :is_watching?

  def name_or_login
    name.blank? ? login : name
  end

  protected
    
    # send a Jabber test message if
    # * the address was changed, but only if option is enabled
    # * the option was re-enabled
    def send_test_message_if_changed
      old = User.find(self.id)
      if self.notify_via_jabber? and (old.jabber != self.jabber or !old.notifiable_via_jabber?)
        Notifier.send_test(self)
        self.sent_test_message = true
      end
    end


end
