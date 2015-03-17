# Cct - Cucumber Cloud Testsuite

  The `master` branch contains the testsuites for the product being currently in
  development cycle. Code for the already released versions are available in
  appropriate branches of this repo.

## Installation

     git clone git@github.com:vmoravec/cct

     bundle install

  If you are not using any Ruby version manager you will be prompt for root password.

## Dependencies

  They are to be found in the cct.gemspec file.

  Currently the main dependency is cucumber testing framework (`rake` and `bundler` are
  part of ruby installation). Due to making use of features which are not available
  in the stable cucumber version (>= 1.3), we rely on rubygem available at
  rubygems.org and not the rpm `rubygem-cucumber` available in opensuse repos.

  For testing the code in `lib` directory we use `rspec` framework.

## Usage

     rake -T

  or

     rake help

## Contributing

1. Fork it ( https://github.com/[my-github-username]/cct/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
