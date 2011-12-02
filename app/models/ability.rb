class Ability
  include CanCan::Ability

  def logged?
    !@user.new_record?
  end

  def admin?
    @user.admin?
  end

  def initialize(user)
    user ||= User.new
    @user = user

    unless logged?
      can [:new, :create], User
    end

    if admin?
      can :manage, :all
    end

    can [:show, :activate], User do |u|
      u == user
    end

    can :resend_code, User do |u|
      u == user && !u.activated?
    end
  end
end
