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

  To get rid of the annoying `rake` command prefixing with `bundle exec`, having done

     alias rake="bundle exec rake"

  might be useful. The command `bundle exec` takes care about locating and loading
  the correct rubygems from the pre-configured path in `vendor/bundle` that is present
  at `.bundle/config`.

  If you get an error like

    rake aborted!
    LoadError: cannot load such file -- cucumber
    /home/path/to/code/cct/Rakefile:6:in `<top (required)>'

  the rubygems installed in path `vendor/bundle` are not visible to `rake`.

## Useful commands

  Get some help:

     rake help
     rake h
     rake -T
     rake -T keyword

  Run unit tests for code inside `lib` directory:

     rake spec

## Configuration

  Show the current configuration:

     rake config

  By default the testsuite contains two configuration files:

     config/default.yml
     config/development.yml

  The first one, `config/default.yml` contains general information about the product,
  used by the features and test cases in the testsuite. You should not need to alter
  these data at all. If you think they need to be changed, create a pull request.

  The second one, `config/development.yml` is a template configuration file you
  might use for testing your cloud instance. You will need to add some data to let
  the testsuite detect your cloud:

    * ip address for the admin node
    * password for the admin node HTTP API
    * SSH password for the admin node unless you use key based authentication

  To let git ignore the updated `config/development.yml` file, run

    rake git:ignore file=config/development.yml

  If you think you might need to add more configuration files, add them into the
  `config/` directory, they will be ignored by git. To make the testsuite load them
  for you, add this line to the `config/development.yml` file:

    autoload_config_files:
     - your_file.yml

  If the file you added does not exist, the testsuite will fail.

  Additionally, you can provide configuration data in `json` or `yaml` format to
  every `rake` command like this:

    rake feature:admin config='{"admin_node":{"remote":{"ip":"192.168.199:10"}}}'






## Contributing

1. Fork it!
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
