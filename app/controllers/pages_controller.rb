class PagesController < ApplicationController
  def index
    path = Rails.root.join('app/views/layouts/liquid/page.liquid')
    liquid = File.read(path)
    template = Liquid::Template.parse(liquid)
    tolgee_registers = TolgeeLiquid.registers({
      locale: 'zh-TW',
      mode: params[:mode],
      static_data: {
        en: YAML.load_file(Rails.root.join('config', 'locales', 'en.yml')),
        'zh-TW': YAML.load_file(Rails.root.join('config', 'locales', 'zh-TW.yml')),
      },
    })
    puts(YAML.load_file(Rails.root.join('config', 'locales', 'en.yml')))
    @content = template.render({}, registers: tolgee_registers)
  end
end
