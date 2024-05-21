Tolgee.configure do |config|
  config.api_url = 'http://localhost:8085'
  config.api_key = 'tgpak_gjpwcmdunfzdk3dhg5sdo2thgzudqmjvg5thanjtnfvhc'
  config.project_id = '2'

  config.static_data = {
    en: YAML.load_file(Rails.root.join('config', 'locales', 'en.yml')),
    'zh-TW': YAML.load_file(Rails.root.join('config', 'locales', 'zh-TW.yml')),
  }
end
