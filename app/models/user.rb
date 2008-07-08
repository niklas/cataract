require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login,    :case_sensitive => false
  validates_format_of       :login,    :with => RE_LOGIN_OK, :message => MSG_LOGIN_BAD

  validates_format_of       :name,     :with => RE_NAME_OK,  :message => MSG_NAME_BAD, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email,    :case_sensitive => false
  validates_format_of       :email,    :with => RE_EMAIL_OK, :message => MSG_EMAIL_BAD

  validates_length_of       :jabber, :on => :update,   :within => 3..100, :allow_nil => true

  has_many :watchings, :dependent => :destroy
  has_many :torrents, :through => :watchings

  has_many :comments

  model_stamper
  

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :jabber, :notify_via_jabber


  def notifiable_via_jabber?
    notify_via_jabber? and !jabber.blank?
  end

  def watch(torrent)
    return if is_watching?(torrent)
    torrent.log('is now watched')
    self.watchings.create(:torrent => torrent, :apprise => true)
  end

  def unwatch(torrent_id)
    w = self.watchings.find_by_torrent_id(torrent_id)
    if w
      w.destroy 
      torrent.log('is not watched anymore')
    end
  end

  def is_watching?(torrent)
    watchings.find_by_torrent_id(torrent.id)
  end
  alias_method :watches?, :is_watching?

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

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
