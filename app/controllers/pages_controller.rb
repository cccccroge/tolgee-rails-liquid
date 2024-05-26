class PagesController < ApplicationController
  def index
    path = Rails.root.join('app/views/layouts/liquid/page.liquid')
    liquid = File.read(path)
    template = Liquid::Template.parse(liquid)
    tolgee_registers = Tolgee.liquid_registers({
      locale: 'en',
      mode: 'development',
      static_data: {
        en: YAML.load_file(Rails.root.join('config', 'locales', 'en.yml')),
        'zh-TW': YAML.load_file(Rails.root.join('config', 'locales', 'zh-TW.yml')),
      },
    })
    @content = template.render({}, registers: tolgee_registers)
  end
end
