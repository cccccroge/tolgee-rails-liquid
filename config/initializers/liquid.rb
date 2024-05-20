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
  def initialize(credentials)
    @tolgee_api_url = credentials[:api_url]
    @tolgee_api_key = credentials[:api_key]
    @tolgee_project_id = credentials[:project_id]
  end

  def execute(name, vars = {})
    translation =
      if development?
        dict = get_remote_dict('en')
        string = fetch_translation(dict, name)
        I18n.interpolate(string, **vars.transform_keys(&:to_sym))
      else
        I18n.t(name, **vars.transform_keys(&:to_sym))
      end
    message = { k: name }.to_json
    hidden_message = ZeroWidthCharacterEncoder.new.execute(message)
    "#{translation}#{hidden_message}"
  end

  def development?
    true
  end

  def fetch_translation(dict, name)
    name.split('.'.freeze).reduce(dict) do |level, cur|
      return nil if level[cur].nil?

      level[cur]
    end
  end

  def get_remote_dict(language)
    @remote_dict ||= begin
      url = URI("#{@tolgee_api_url}/v2/projects/#{@tolgee_project_id}/translations/#{language}")
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true if url.scheme == 'https'

      request = Net::HTTP::Get.new(url)
      request['Accept'] = 'application/json'
      request['X-API-Key'] = @tolgee_api_key

      response = http.request(request)
      JSON.parse(response.body)[language]
    end
  end
end

module TolgeeFilter
  def t(name, vars = {})
    translate = Translate.new({
      api_url: 'http://localhost:8085',
      api_key: 'tgpak_gjpwcmdunfzdk3dhg5sdo2thgzudqmjvg5thanjtnfvhc',
      project_id: '2',
    })
    translate.execute(name, vars)
  end
end

Liquid::Template.register_filter(TolgeeFilter)
