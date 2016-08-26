source 'https://rubygems.org'

# Specify your gem's dependencies in cct.gemspec
gemspec

group :ui_tests do
  gem "rack", "~> 1.6" # higher versions require ruby 2.2.2
  gem "capybara"
  # mandatory rpm dependencies for webkit gem
  # zypper install libqt4-devel libQtWebKit-devel   # 120+ packages as deps
  gem "capybara-webkit"
end
