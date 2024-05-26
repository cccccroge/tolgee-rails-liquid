require 'net/http'

class ZeroWidthCharacterEncoder
  INVISIBLE_CHARACTERS = ["\u200C", "\u200D"].freeze

  def execute(text)
    bytes = text.bytes
    binary = bytes.map { |byte| to_binary_with_extra_non_join_character(byte) }.join
    to_invisible_string(binary)
  end

  private

  def to_binary_with_extra_non_join_character(byte)
    "#{byte.to_s(2).rjust(8, '0')}0"
  end

  def to_invisible_string(binary)
    binary.chars.map { |bit| INVISIBLE_CHARACTERS[bit.to_i].encode('utf-8') }.join
  end
end

class Translate
  def initialize
    @tolgee_api_url = Tolgee.configuration.api_url
    @tolgee_api_key = Tolgee.configuration.api_key
    @tolgee_project_id = Tolgee.configuration.project_id
  end

  def execute(name, vars = {}, opts)
    locale = opts[:locale]
    dev_mode = opts[:mode] == 'development'
    static_data = opts[:static_data]

    dict = dev_mode ? get_remote_dict(locale.to_s) : static_data[locale.to_sym]
    value = fetch_translation(dict, name)
    return name if value.nil?

    translation = MessageFormat.new(value, locale.to_s).format(vars.transform_keys(&:to_sym))

    if dev_mode
      message = { k: name }.to_json
      hidden_message = ZeroWidthCharacterEncoder.new.execute(message)
      "#{translation}#{hidden_message}"
    else
      translation
    end
  end

  def fetch_translation(dict, name)
    name.split('.'.freeze).reduce(dict) do |level, cur|
      return nil if level[cur].nil?

      level[cur]
    end
  end

  # TODO: error handling
  def get_remote_dict(locale)
    @remote_dict ||= begin
      url = URI("#{@tolgee_api_url}/v2/projects/#{@tolgee_project_id}/translations/#{locale}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.scheme == 'https'

      request = Net::HTTP::Get.new(url)
      request['Accept'] = 'application/json'
      request['X-API-Key'] = @tolgee_api_key

      response = http.request(request)
      JSON.parse(response.body)[locale]
    end
  end
end

module TolgeeFilter
  def t(name, vars = {})
    opts = {
      locale: @context.registers[:locale] || I18n.default_locale,
      mode: @context.registers[:mode] || 'production',
      static_data: @context.registers[:static_data] || {},
    }
    Translate.new.execute(name, vars, opts)
  end
end

module Tolgee
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    def liquid_registers(options)
      options.slice(:locale, :static_data, :mode)
    end

    class Configuration
      attr_accessor :api_url, :api_key, :project_id
    end
  end
end

# TODO: how to wrap a defined `t`?

Liquid::Template.register_filter(TolgeeFilter)
