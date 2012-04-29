class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :manage, Torrent
      can :manage, Directory
    end
  end
end
