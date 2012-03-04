class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :dashboard, User
      can :manage, Torrent
    end
  end
end
