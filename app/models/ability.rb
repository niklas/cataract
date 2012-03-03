class Ability
  include CanCan::Ability

  def initialize(user)
    if user
      can :dashboard, User
      can :index, Torrent
    end
  end
end
