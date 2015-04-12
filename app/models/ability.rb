class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :manage, Torrent
      can :manage, Disk
      can :manage, Directory
      can :manage, Setting
      can :manage, Transfer
      can :manage, :payload # Emu
      can :manage, Torrent::Payload
      can :manage, Move
      can :manage, Feed
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
