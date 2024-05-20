class PagesController < ApplicationController
  def index
    path = Rails.root.join('app/views/layouts/liquid/page.liquid')
    liquid = File.read(path)
    template = Liquid::Template.parse(liquid)
    @content = template.render
  end
end
