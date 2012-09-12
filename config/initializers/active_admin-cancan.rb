# blog post: 

# Before using this initializer, you must set up Cancan. First, add the gem to your Gemfile:
#
#     gem 'cancan'
#
# Next, generate and edit an Ability class:
#
#     rails generate cancan:ability
#
# Then, add the following code to your ApplicationController:
#
#     rescue_from CanCan::AccessDenied do |exception|
#       respond_to do |format|
#         format.html do
#           redirect_to admin_root_path, :alert => exception.message
#         end
#       end
#     end
#
#     def current_ability
#       @current_ability ||= Ability.new(current_admin_user)
#     end
#
# Finally, copy this code to a Rails initializer, like
# config/initializers/active_admin-cancan.rb
module ActiveAdmin
  module ViewHelpers
    # lib/active_admin/view_helpers/auto_link_helper.rb

    def auto_link(resource, link_content = nil)
      content = link_content || display_name(resource)
      if can?(:read, resource) && registration = active_admin_resource_for(resource.class)
        begin
          content = link_to(content, send(registration.route_instance_path, resource))
        rescue
        end
      end
      content
    end
  end

  module Views
    class IndexAsTable
      class IndexTableFor
        # lib/active_admin/views/index_as_table.rb

        def default_actions(options = {})
          options = {
            :name => ""
          }.merge(options)
          column options[:name] do |resource|
            links = ''.html_safe
            if controller.action_methods.include?('show') && can?(:read, resource)
              links += link_to I18n.t('active_admin.view'), resource_path(resource), :class => "member_link view_link"
            end
            if controller.action_methods.include?('edit') && can?(:update, resource)
              links += link_to I18n.t('active_admin.edit'), edit_resource_path(resource), :class => "member_link edit_link"
            end
            if controller.action_methods.include?('destroy') && can?(:destroy, resource)
              links += link_to I18n.t('active_admin.delete'), resource_path(resource), :method => :delete, :data => {:confirm => I18n.t('active_admin.delete_confirmation')}, :class => "member_link delete_link"
            end            
            links
          end
        end
      end
    end
  end

  class Resource
    # lib/active_admin/resource/menu.rb

    # The :if block is evaluated by TabbedNavigation#display_item?
    def default_menu_options
      klass = resource_class # avoid variable capture
      super.merge(:if => proc{ can? :read, klass })
    end

    # lib/active_admin/resource/action_items.rb

    def add_default_action_items
      # New Link on all actions except :new and :show
      add_action_item(:except => [:new, :show], :if => proc{ can? :create, active_admin_config.resource_class }) do
        if controller.action_methods.include?('new')
          link_to(I18n.t('active_admin.new_model', :model => active_admin_config.resource_label), new_resource_path)
        end
      end

      # Edit link on show
      add_action_item(:only => :show, :if => proc{ can? :update, resource }) do
        if controller.action_methods.include?('edit')
          link_to(I18n.t('active_admin.edit_model', :model => active_admin_config.resource_label), edit_resource_path(resource))
        end
      end

      # Destroy link on show
      add_action_item(:only => :show, :if => proc{ can? :destroy, resource }) do
        if controller.action_methods.include?("destroy")
          link_to(I18n.t('active_admin.delete_model', :model => active_admin_config.resource_label),
            resource_path(resource),
            :method => :delete, :data => {:confirm => I18n.t('active_admin.delete_confirmation')})
        end
      end
    end
  end

  class ResourceController
    # lib/active_admin/resource_controller/collection.rb

    # The following doesn't work (see https://github.com/ryanb/cancan/pull/683):
    #
    #     load_and_authorize_resource
    #     skip_load_resource :only => :index
    #
    # If you don't skip loading on #index you will get the exception:
    #
    #     "Collection is not a paginated scope. Set collection.page(params[:page]).per(10) before calling :paginated_collection."
    load_resource :except => :index
    authorize_resource

    # https://github.com/gregbell/active_admin/wiki/Enforce-CanCan-constraints
    # https://github.com/ryanb/cancan/blob/master/lib/cancan/controller_resource.rb#L80
    def scoped_collection
      end_of_association_chain.accessible_by(current_ability)
    end
  end
end
