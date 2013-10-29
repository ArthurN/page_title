require "i18n"
require "forwardable"
require "page_title/engine"
require "page_title/helpers"
require "page_title/version"

module PageTitle
  class Base
    # Set all action aliases.
    ACTION_ALIAS = {
      "update" => "edit",
      "create" => "new",
      "destroy" => "remove"
    }

    # Set the controller instance. It must implement
    # the methods controller_name and action_name.
    attr_reader :controller

    # Set the main translation options.
    attr_reader :options

    extend Forwardable
    def_delegators :options, :[], :[]=, :merge!

    def initialize(controller)
      @controller = controller
      @options = {}
    end

    def to_s
      base_translation
    end

    private
    # Looks up translations for page title in this order:
    #   titles.CONTROLLER.ACTION
    #   titles.controllers.CONTROLLER
    #   titles.actions.ACTION
    def title_translation
      I18n.t(
        normalized_action_name,
        options.merge(scope: "titles.#{normalized_controller_name}",
                      default: I18n.t(normalized_controller_name, 
                                      scope: 'titles.controllers', 
                                      default: I18n.t(normalized_action_name, 
                                                      scope: 'titles.actions',
                                                      default: '')))
      )
    end

    # If we can get a title_translation based on controller name and/or action name, then
    # we insert that into the base title translation. If not, we just use whatever's in titles.base_notitle.
    def base_translation
      title = title_translation
      title.blank? ? I18n.t('titles.base_notitle') : I18n.t('titles.base', title: title_translation)
    end

    def normalized_action_name
      ACTION_ALIAS.fetch(controller.action_name, controller.action_name)
    end

    def normalized_controller_name
      controller.class.name.underscore
        .gsub(/_controller/, "")
        .gsub(%r[/], ".")
    end

    def title_scope
      [normalized_controller_name, normalized_action_name].join(".")
    end
  end
end
