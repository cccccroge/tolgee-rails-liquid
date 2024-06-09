# tolgee-rails-liquid
An example project that demo [tolgee liquid](https://github.com/cccccroge/tolgee_liquid), which integrates the Tolgee Platform with Shopify's Liquid template language.

## Setup
- provide tolgee information in `config/initializers/tolgee.rb`
- register liquid filter in `config/initializers/liquid.rb`
- demo page is implemented through `app/views/layouts/liquid/page.liquid` and `app/controllers/pages_controller.rb`
- tolgee.js is included in `app/javascript/application.js`
- start server via `bin/rails server`

## Demo
### production mode
Go to `http://127.0.0.1:3000/demo?mode=production`

### development mode
Go to `http://127.0.0.1:3000/demo?mode=development`

