// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import { Tolgee, DevTools } from '@tolgee/web';
import { FormatIcu } from '@tolgee/format-icu';

// TODO: need a way to sync with server side
const isDevelopment = true

if (isDevelopment) {
  const tolgee = Tolgee().use(DevTools()).use(FormatIcu()).init({
    language: 'en',
    fallbackLanguage: 'en',
    observerType: 'invisible',
  });
  tolgee.run();
}
