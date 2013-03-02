class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :manage, Torrent
      can :manage, Disk
      can :manage, Directory
      can :manage, Setting
      can :manage, Torrent::Transfer
      can :manage, Torrent::Payload
      can :create, Torrent::Deletion # can delete torrent, including its Payload
      can :manage, Move
    end

    unless settings.disable_signup?
      can :create, User
    end
  end

  private
  def settings
    @settings ||= Setting.singleton
  end
end
