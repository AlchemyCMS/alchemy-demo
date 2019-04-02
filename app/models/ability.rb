class Ability
  include CanCan::Ability
  include Alchemy::Permissions::AuthorUser

  def initialize(user)
    return if user.nil?
    @user ||= user
    if @user.has_role?(:demo)
      alchemy_author_rules

      # Navigation
      can [:index], :alchemy_admin_languages
      can [:index], :alchemy_admin_sites
      can [:index], :alchemy_admin_users

      # Controller actions
      can [:info, :update_check], :alchemy_admin_dashboard
      can :clear, :trash

      # Resources
      can [
        :copy,
        :copy_language_tree,
        :flush,
        :order,
        :sort,
        :switch_language
      ], Alchemy::Page

      can([
        :create,
        :destroy,
        :publish
      ], Alchemy::Page) { |p| p.editable_by?(@user) }

      can [:index, :edit], Alchemy::Language
      can [:index, :edit], Alchemy::Site
      can [:index, :edit, :update], Alchemy::Picture
      can [:index], Alchemy.user_class
      can [:update], Alchemy.user_class, id: user.id
      can [:manage], Alchemy::Tag
    end
  end
end
