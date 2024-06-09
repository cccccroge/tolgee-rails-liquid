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
<img width="648" alt="SCR-20240609-ujaj" src="https://github.com/cccccroge/tolgee-rails-liquid/assets/17543132/c5762aa3-5d6a-401f-82ec-47582d7d8218">

### development mode
Start your tolgee server and go to `http://127.0.0.1:3000/demo?mode=development`
![demo_gif](https://github.com/cccccroge/tolgee-rails-liquid/assets/17543132/e1ff109b-c307-4133-9b6d-e8673db25d2a)



