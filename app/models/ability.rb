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
      can :update, Torrent::Deletion # can delete torrent, including its Payload (id must be present thx to Emu DELETE)
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
