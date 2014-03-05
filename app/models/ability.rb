class Ability
  include CanCan::Ability
  include Alchemy::Permissions::EditorUser

  def initialize(user)
    return if user.nil?
    @user ||= user
    if @user.has_role?(:demo)
      alchemy_editor_rules

      # Navigation
      can :index,                 [:alchemy_admin_sites]

      # Controller actions
      can [:info, :update_check], :alchemy_admin_dashboard

      # Resources
      can :show, Alchemy::Page, public: true
      can :index, Alchemy::Site
      can :index, Alchemy::Language
    end
  end

end
