# cct - Cucumber Cloud Testsuite

  The `master` branch contains the testsuites for SUSE Cloud 5.
  Testsuites for other versions of cloud will be available in repository branches.

## Installation

  Make sure you have installed all [dependencies](#Dependencies)

     git clone git@github.com:vmoravec/cct

     bundle install

  All rubygems will be installed into the directory `vendor/bundle` within the repo.

  This is the default setup, if you use one of Ruby version managers like `RVM`,
  you might want to create a new gemset and override the bundle config with:

     bundle install --system

## Dependencies

    zypper in rubygem-bundler ruby-devel
    zypper in gcc make

  List of required rubygems can be found in file `cct.gemspec` .

## Usage

     bundle exec rake help

  To get rid of the annoying command overload, having done

     alias rake="bundle exec rake"

  might be useful.

  If you get an error like

    rake aborted!
    LoadError: cannot load such file -- cucumber
    /home/path/to/code/cct/Rakefile:6:in `<top (required)>'

  the rubygems installed in path `vendor/bundle` are not visible to `rake`.

## Commands

### Get some help

     rake help
     rake h
     rake -T
     rake -T keyword

### Run unit tests for code inside `lib` directory

     rake spec

### Show the current configuration

     rake config


## Contributing

1. Fork it!
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
