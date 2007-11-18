# == Schema Information
# Schema version: 28
#
# Table name: users
#
#  id                        :integer       not null, primary key
#  name                      :string(255)   
#  login                     :string(255)   
#  email                     :string(255)   
#  jabber                    :string(255)   
#  notify_via_jabber         :boolean       
#  notify_on_comments        :boolean       
#  notify_on_my_torrents     :boolean       
#  picture_url               :string(255)   
#  crypted_password          :string(40)    
#  salt                      :string(40)    
#  created_at                :datetime      
#  updated_at                :datetime      
#  notify_on_new_torrents    :boolean       
#  dont_watch_new_torrents   :boolean       
#  content_dir_mountpoint    :text          
#  target_dir_mountpoint     :text          
#  remember_token            :string(255)   
#  remember_token_expires_at :datetime      
#

require 'digest/sha1'
class User < ActiveRecord::Base
  hobo_user_model
  set_login_attr :login
  alias_attribute :to_s, :name

  has_many :watchings, :dependent => :destroy
  has_many :torrents, :through => :watchings

  has_many :comments
  # Virtual attribute for the unencrypted password
  attr_accessor :password
  # did we sent a message? (for the controller#flash)
  attr_accessor :sent_test_message

  validates_presence_of     :login, :email
  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required?
  validates_length_of       :password, :within => 4..40, :if => :password_required?
  validates_confirmation_of :password,                   :if => :password_required?
  validates_length_of       :login,    :within => 3..40
  validates_length_of       :email,    :within => 3..100
  validates_length_of       :jabber, :on => :update,   :within => 3..100
  validates_uniqueness_of   :login, :email, :case_sensitive => false
  before_save :encrypt_password 
  before_update :send_test_message_if_changed

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  def self.authenticate(login, password)
    u = find_by_login(login) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def notifiable_via_jabber?
    notify_via_jabber? and !jabber.empty?
  end

  def watch(torrent)
    return if is_watching(torrent)
    self.watchings.create(:torrent => torrent, :apprise => true)
  end

  def unwatch(torrent_id)
    w = self.watchings.find_by_torrent_id(torrent_id)
    w.destroy if w
  end

  def is_watching(torrent)
    watchings.find_by_torrent_id(torrent.id)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at 
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    self.remember_token_expires_at = 2.weeks.from_now.utc
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  protected
    # before filter 
    def encrypt_password
      return if password.blank?
      self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
      self.crypted_password = encrypt(password)
    end
    
    def password_required?
      crypted_password.blank? || !password.blank?
    end

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
