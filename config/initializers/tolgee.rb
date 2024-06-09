TolgeeLiquid.configure do |config|
  config.api_url = Rails.application.credentials.dig(:tolgee, :api_url)
  config.api_key = Rails.application.credentials.dig(:tolgee, :api_key)
  config.project_id = Rails.application.credentials.dig(:tolgee, :project_id)
end
