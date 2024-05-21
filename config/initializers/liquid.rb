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
    @static_data = Tolgee.configuration.static_data
  end

  def execute(name, vars = {}, locale)
    translation =
      if development?
        dict = get_remote_dict(locale.to_s)
        string = fetch_translation(dict, name)
        MessageFormat.new(string, locale.to_s).format(vars.transform_keys(&:to_sym))
      else
        dict = @static_data[locale.to_sym]
        string = fetch_translation(dict, name)
        MessageFormat.new(string, locale.to_s).format(vars.transform_keys(&:to_sym))
      end

    # TODO: need a way to sync with client side
    if development?
      message = { k: name }.to_json
      hidden_message = ZeroWidthCharacterEncoder.new.execute(message)
      "#{translation}#{hidden_message}"
    else
      translation
    end
  end

  def development?
    true
  end

  # TODO: show name if not found
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
    locale = @context.registers[:locale] || I18n.default_locale
    Translate.new.execute(name, vars, locale)
  end
end

module Tolgee
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration)
    end

    class Configuration
      attr_accessor :api_url, :api_key, :project_id, :static_data

      def initialize
        @static_data = {}
      end
    end
  end
end

# TODO: how to wrap a defined `t`?

Liquid::Template.register_filter(TolgeeFilter)
