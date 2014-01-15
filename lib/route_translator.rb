require 'active_support'
require 'action_controller'
require 'action_mailer'
require 'action_dispatch'

require File.expand_path('../route_translator/extensions', __FILE__)
require File.expand_path('../route_translator/translator', __FILE__)

module RouteTranslator

  TRANSLATABLE_SEGMENT = /^([-_a-zA-Z0-9]+)(\()?/.freeze

  Configuration = Struct.new(:force_locale, :generate_unlocalized_routes, :translation_file, :locale_param_key, :generate_unnamed_unlocalized_routes, :default_locale, :included_locales)

  def self.config(&block)
    @config ||= Configuration.new
    @config.force_locale ||= false
    @config.generate_unlocalized_routes ||= false
    @config.locale_param_key ||= :locale
    @config.generate_unnamed_unlocalized_routes ||= false
    @config.default_locale ||= I18n.default_locale
    @config.included_locales ||= I18n.available_locales.dup
    # require that default locale is included in list of all locales
    unless @config.default_locale.in? @config.included_locales
      raise "Default locale #{@config.default_locale} not included in locales: #{@config.included_locales}"
    end
    # Make sure the default locale is translated in last place to avoid
    # problems with wildcards when default locale is omitted in paths. The
    # default routes will catch all paths like wildcard if it is translated first
    @config.included_locales.delete @config.default_locale
    @config.included_locales.push @config.default_locale

    yield @config if block
    @config
  end

  def self.locale_param_key
    self.config.locale_param_key
  end

end
