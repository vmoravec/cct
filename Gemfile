source 'https://rubygems.org'

# Specify your gem's dependencies in cct.gemspec
gemspec

group :ui_tests do
  gem "rack", "~> 1.6" # higher versions require ruby 2.2.2
  gem "capybara"
  gem "capybara-screenshot"
  # mandatory rpm dependencies for webkit gem
  # zypper install libqt4-devel libQtWebKit-devel xorg-x11-server xorg-x11-server-extra
  gem "capybara-webkit", "~> 1.11.1"
  # mandatory rpm dependencies for headless gem
  # zypper install xorg-x11-server xorg-x11-server-extra
  gem "headless"
end
