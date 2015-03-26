# cct - Cucumber Cloud Testsuite

  The `master` branch contains the testsuites for SUSE Cloud 5.
  Testsuites for other versions of cloud will be available in repository branches.

## Topics

  I    [Installation](#installation)  
  II   [Dependencies](#dependencies)  
  III  [Usage](#usage)  
  IV   [Configuration](#configuration)  
  V    [Tasks](#tasks) missing  
  VI   [Features](#features)  
  VII  [Code](#code) missing  


## Quick start

  1.  Check [system dependencies](#dependencies)
  2.  `git clone git@github.com:vmoravec/cct`
  3.  `cd cct && bundle install`
  4.  Add missing data into `config/development.yml` file
  5.  `rake feature:admin`


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

## Crash course

#### Run a feature

    rake feature:admin

#### Run a test/scenario

    rake featuer:admin:ntp

#### Rake task is your friend

    rake help

  `rake` is the only way to run the tests and other commands. All files with tasks
  are located in the directory `tasks/` and have suffix `.rake`
  All are loaded automatically. Just
  put `your_new.rake` file into the directory and add your tasks.

  A single file usually contains several tasks within some well chosen namespace.

  In general there is 2 kinds of tasks:

    * regular rake tasks => for managing testsuite and providing help 
    * feature rake task  => for running cucumber features


#### Add new feature

    rake add:feature

#### Add new test

    rake add:test

#### Add new code to `lib/`

  Lorem ipsum


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

#### Useful commands

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


#### Default config files

  By default the testsuite contains two configuration files:

     config/default.yml
     config/development.yml

  The first one, `config/default.yml` contains general information about the product,
  used by the features and test cases in the testsuite. You should not need to alter
  this data at all. If you think they need to be changed, create a pull request.

  The second one, `config/development.yml` is a template configuration file you
  might use for testing your cloud instance. You will need to add some data to let
  the testsuite detect your cloud:

    * ip address for the admin node
    * password for the admin node HTTP API
    * SSH password for the admin node unless you use key based authentication

  To let git ignore the updated `config/development.yml` file, run

    rake git:ignore file=config/development.yml


#### Custom config files

  If you think you might need to add more configuration files, add them into the
  `config/` directory, they will be ignored by git. To make the testsuite load them
  for you, add this line to the `config/development.yml` file:

    autoload_config_files:
     - your_file.yml

  The config files are loaded in the order as specified in the list. Don't forget
  that if you have the same sections in your config files, the last loaded file wins.

  If the file you added does not exist, the testsuite will fail.


#### Custom config data as json or yaml

  Additionally, you can provide configuration data in `json` or `yaml` format to
  every `rake` command like this:

    rake feature:admin config='{"admin_node":{"remote":{"ip":"192.168.199:10"}}}'

  These are merged with the data after all configuration files have been loaded.


## Features

  The testsuite is powered by `cucumber` which is a tool for running automated
  tests written in plain language. More information is available at the
  [Cucumber Github Wiki](https://github.com/cucumber/cucumber/wiki/A-Table-Of-Content).

#### Feature files

  All features are stored in files with `.feature` suffix in the directory `features/`.
  Every file describes a single feature with one or more scenarios using
  [Gherkin](https://github.com/cucumber/cucumber/wiki/Gherkin).
  It is a Domain Specific Language that lets you describe behaviour without detailing
  how that behaviour is implemented.

#### Run a feature!

  The command line interface is powered by `rake` which is a task management tool,
  more information is available at the [rake Github repo](https://github.com/ruby/rake).

  Feature tasks begin with `feature` keyword, to test only a particular scenario you need
  to run some specific `rake` task:

    rake feature:admin       # Run all scenarios for admin node
    rake feature:admin:ntp   # Test NTP Server availability on admin node
    rake feature:admin:os    # Check operating system support for admin node





## Contributing

1. Fork it!
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
