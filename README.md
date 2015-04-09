# cct - Cucumber Cloud Testsuite

  The `master` branch contains the testsuites for SUSE Cloud 5.
  Testsuites for other versions of cloud will be available in respective branches.

## Topics

  [Installation](#installation)  
  [Dependencies](#dependencies)  
  [Usage](#usage)  
  [How-To's](#how-tos)  
  [Configuration](#configuration)  
  [Code](#code) missing  
  [Tasks](#tasks) missing  
  [Features](#features)  


## Quick start

  1.  Check [system dependencies](#dependencies)
  2.  `git clone git@github.com:suse-cloud/cct`
  3.  `cd cct && bundle install`
  4.  Add missing data into `config/development.yml` file
  5.  `rake feature:admin`


## Installation

  Make sure you have installed all [dependencies](#dependencies)

  After you have cloned the repository, install the required rubygems:

     bundle install

  All rubygems will be installed into the directory `vendor/bundle` within the repo.

  This is the default setup, if you use one of Ruby version managers like `RVM`,
  you might want to create a new gemset and override the bundle config
  in `.bundle/config` with:

     bundle install --system


## Dependencies

    zypper in rubygem-bundler ruby-devel
    zypper in gcc make

  List of required rubygems can be found in file `cct.gemspec` and in `Gemfile`.


## How-To's

#### Make use of `rake console`

  Once you have entered configuration data for the admin node, it's handy
  to get some live data from the deployed cloud within an ruby's irb session.

  `rake console` will give you access to admin node, control node, crowbar API
  and some other useful stuff used in the cucumber step definitions.

  To make it more verbose, call it with `rake console --verbose`

#### Write a new feature

  There are two requirements for a new feature:

  * new cucumber feature file in path `features/` that must have `.feature` extension
  * new rake task file in path `tasks/` with `.rake` extension

  There is also a dedicated `rake` task available for creating both of them:

    rake add:feature name='Awesome Stuff' task='awesome_stuff'

  Look into the directory `templates/` where templates for both files are stored.
  Try to keep the name of the `rake` task short but still expressive.

#### Write a new scenario

  Every cucumber feature is composed of one or more scenarios. A scenaro consists
  of steps that describe what is being tested.

  A scenario is a concept based on Givens, Whens and Thens.
  The purpose of __Given__ is to put the system in a known state or to find out
  whether the system is in state ready for testing.

  The purpose of __When__ is to describe the key action the actor (system or user)
  performs.

  The purpose of __Then__ step is to observe outcomes. The observations
  should be related to the feature description.

  Beside these, you can use __And__ and __But__ keywords to make the scenario
  more descriptive or specific.


#### Write a step definition

  Once the scenario is written

#### Use commands in the step definitions

#### Add new command for the step definitions

#### Run a single feature

    rake feature:FEATURE_NAME

#### Run a scenario

    rake feature:FEATURE_NAME:SCENARIO_NAME

#### Rake task is your friend

    rake help


#### Add new feature

    rake add:feature

#### Add new test

    rake add:test

#### Add new code to `lib/`

    TODO


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

  `rake` is the only way to run the tests and other commands. All files with tasks
  are located in the directory `tasks/` and have suffix `.rake`
  All are loaded automatically.

  A single file usually contains several tasks within some well chosen namespace.

  In general there is 2 kinds of tasks:

    * regular rake tasks => for managing various stuff and providing help 
    * feature rake task  => for running cucumber features and scenarios

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

#### Disclaimer

  This documenation contains information and formulations available on 
  [cucumber github wiki](https://github.com/cucumber/cucumber/wiki). 


## Contributing

1. Fork it!
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

