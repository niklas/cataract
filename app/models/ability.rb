class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :manage, Torrent
    end
  end
end
