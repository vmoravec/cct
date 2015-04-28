# cct - Cucumber Cloud Testsuite

  The `master` branch contains the testsuites for SUSE Cloud 5.
  Testsuites for other versions of cloud will be available in respective branches.

## Topics

  [Installation](#installation)  
  [Dependencies](#dependencies)  
  [Usage](#usage)  
  [How-To's](#how-tos)  
  [Configuration](#configuration)  
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


## Usage

     bundle exec rake help

  To get rid of the annoying `rake` command prefixing with `bundle exec`, having done

     alias rake="bundle exec rake"

  might be useful. The command `bundle exec` takes care about locating and loading
  the correct rubygems from the pre-configured path as set by `.bundle/config`.

  If you get an error like

    rake aborted!
    LoadError: cannot load such file -- cucumber
    /home/path/to/code/cct/Rakefile:6:in `<top (required)>'

  the rubygems installed in path `vendor/bundle` are not visible to `rake`.

  `rake` is the preferred way to run the tests and other commands. All files with tasks
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


## How-To's

#### Make use of `rake console`

  Once you have added your configuration for the admin node, it's handy
  to get some live data from the deployed cloud in an ruby's irb session.

  `rake console` will give you access to admin node, control node, crowbar API
  and some other useful stuff used in the cucumber step definitions.

  To make it more verbose, call it with `rake console --verbose`

#### Write a new feature

  There is a dedicated `rake` task available for creating all the necessaries:

    `rake add:feature name='Awesome Stuff' task='awesome_stuff'`  


  Try to keep the name of the `rake` task short but still expressive. Multiple
  words must be combined with underscore.

  Two new files will be created for a new feature:

    * new cucumber feature file in path `features/` that must have `.feature` extension  
    * new rake task file in path `tasks/` with `.rake` extension  

  Look into the directory `templates/` where the templates for both files are stored.


#### Write a new scenario

  Every cucumber feature is composed of one or more scenarios. A scenaro consists
  of its name and steps that describe what is being tested.

  A scenario is a concept based on *Givens*, *Whens* and *Thens*.

  The purpose of __Given__ is to put the system in a known state or to find out
  whether the system is in state ready for testing.

  The purpose of __When__ is to describe the key action the actor (system or user)
  performs.

  The purpose of __Then__ step is to observe outcomes. The observations
  should be related to the feature description.

  Beside these you can use __And__ and __But__ keywords to make the scenario
  more descriptive or specific.

  Don't forget to add a *tag* above the scenario name in the form of
  a single word that expresses the scenario name, like `@packages` . This tag
  will be used inside of a feature rake task to call that single scenario only.

  If you are still not sure how to write a scenario, better look at the existing
  features and make your own judgment.


#### Use scenario configuration

  If you find yourself writing similar scenarios with different configurations,
  you might want to make use of scenario specific config values. You can put these
  into `config/features/FEATURE_NAME.yml`

  This file must have structure like this:

  ```yaml
  features:
    admin:
      ntp:
        key_one: abcd
        key_two: efcg
  ```

  You can access these config values either manually by
  `config["features"]["admin"]["ntp"]["key_one"]` or by using a method with block:

  ```ruby
  # Put this into some step definition block
  with_scenario_config do |config|
    puts config["key_one"]
    puts config["key_two"]
  end
  ```
  If there configuration for this scenario is empty, the code within the block will
  be not executed. (Maybe raising an exception like `ConfigurationNotFound` would be 
  better?).

  This configuration is loaded in a `Before` hook in `features/support/env.rb` and
  is based on the `tags` used for the `feature` and `scenario`.

  It works only when a `feature` has a __single tag__. At the scenario level the
  first `tag` is used, the rest is ignored.


#### Write a step definition

  Once the scenario is written, you should adapt the respective feature rake task
  to let it run via `rake` (more on this [here](#run-a-single-scenario-with-a-rake)).

  When the steps does not match any already existing step
  definition the scenario will be marked as *undefined* with this notice:

  ```
  You can implement step definitions for undefined steps with these snippets:

  Given(/^I have my system in the okay state$/) do
    pending # Write code here that turns the phrase above into concrete actions
  end
  ```
  Now you copy the text above starting with `Given`, go to the directory
  `features/step_definitions/YOUR_FEATURE`, create a new file with name matching
  the scenario name and with suffix `_steps.rb`. Insert the copied text from above.

  The last step is to replace the `pending` method with your test implementation.
  More about that you can find in the section about
  [commands in step definitions](#what-commands-to-use-in-step-definitions) .



#### Run a single scenario with `rake`

  To be able to run a single scenario, you need to mark it with a unique `@tag`. Then
  in rake you must implement a specific task that will call the feature with that
  `@tag`. A `rake` task for a feature might look like this:

  ```ruby
  namespace :feature do
    feature_name "Admin node"

    namespace :admin do
      desc "Test NTP Server availability"
      feature_task :ntp, tags: :@ntp
    end
  end
  ```

  It looks up the feature with name `Admin node`, creates a `rake` task with name
  `:ntp` within the namespace `:admin`. To call this task you need to type:

  ```
  rake feature:admin:ntp
  ```

#### Run a complete feature with `rake`

  There needs to be a standalone `rake` task implemented to make a feature run
  complete. It's done by a separate task without description like this:

  ```ruby
  namespace :feature do
    feature_name "Controller node"

    namespace :controller do
      desc "Essential system requirements"
        feature_task :system, tags: :@system
        feature_task :all # Define it here like this
      end

      # One task to rule them all
      desc "Complete verification of 'Controller node' feature"
      task :controller => "controller:all"
    end
  ```
  Now call the whole feature with:

  ```
    rake feature:controller
  ```

  We created a new task without any specific `@tags`, that means everything what
  is found within the feature is run.


#### What commands to use in step definitions

  The ruby commands available in the step definitions are defined by code in the
  file `features/support/env.rb` :

  ```ruby
  World do
    Cct::Cloud::World.new
  end
  ```
  The actual ruby code is available in `lib/cct/cloud/world.rb`

  Helper commands are also loaded by this:

  ```ruby
  World(StepHelpers)
  ```

  The code is available in `features/support/step_helpers.rb`. There should be only
  step or scenario specific code placed here, the right place for new commands is in
  `lib/cct/commands/`.

  Currently available __local__ commands are these:  

  `exec!` expects a command name with arguments as parameter  
  `ping!` expects a node instance as parameter  
  `ssh_hadnshake!` expects a node instance as parameter  

  Commands to call __remotely__ on the node instances:  

  `exec!` expects a command name with arguments as parameter  
  `read_file` expects a path on the remote machine as parameter  
  `rpm_q` expects a package name as parameter  

  Both `exec!` commands return a struct object with three attributes: `output`,
  `success?` and `exit_code`. 

  If the execution of the `exec!` command has failed, an exception is thrown.
  You should not rescue these exceptions as it's important to see and log the
  source of the primary problem.

  Additionally, you can use built-in matchers of `rspec` unit test framework.
  There is a big variety of the matchers for various situations, you rather look
  at them at [rspec matchers docs](https://www.relishapp.com/rspec/rspec-expectations/docs/built-in-matchers) .
  Here is a bit more detailed doc about how to [customize the matchers](http://www.relishapp.com/rspec/rspec-expectations/v/3-2/docs).


#### Add new command for the step definitions

  The rule of thumb is when you use a remote or local command on more than 3 places,
  let's it implement as a predefined command within the `lib/cct/commands`.
  Don't forget to add unit test to the new command.


#### Add new code to `lib/`

  If you find a bug or you want to propose an improvement, please create a pull request.
  Every new code for the `lib/` directory must have `rspec` unit tests.

## Configuration

  Show the current configuration:

     rake config


#### Default config files

  By default the testsuite contains two configuration files:

     config/default.yml
     config/development.yml.example

  The first one, `config/default.yml` contains general information about the product,
  used by the features and test cases in the testsuite. You don't alter
  this data for your custom configuration. If you think they need to be changed, create a pull request.

  The second one, `config/development.yml.example` is a template configuration file you
  might use for testing your cloud instance. You may uncomment and use the template data, however
  they might not match your expactations. Feel free to change the data as needed to make
  the testsuite detect your cloud:

    * ip address for the admin node
    * password for the admin node HTTP API
    * SSH password for the admin node unless you use key based authentication

  All configuration files but the `default.yml` file are ignored by git.


#### Nodes' configuration

  The `development.yml` config file contains this section:

  ```yaml
  nodes:
    - name:
      ssh:
        user: root
        password:
  ```
  Here you can configure the ssh credentials for the respective nodes
  (beside admin node which is configured in its own section).

  If you want to add a configuration for some specific node, please copy
  the whole section beggining with `name` and keep the default one untouched.

  At least one section should keep the `name` attribute empty, this setup is
  considered as default and will be used for the rest of nodes who share the
  same configuration for `ssh` part.

  Usually the only thing you might want to change is the `password` attribute.
  For the `name` attribute you can use either a hostname or a FQDN.


#### Custom config files

  If you think you might need to add more configuration files, add them into the
  `config/` directory, they will be ignored by git. To make the testsuite load them
  for you, add this line to the `config/development.yml` file:

  ```yaml
  autoload_config_files:
   - your_file.yml
  ```

  The config files are loaded in the order as specified in the list. Don't forget
  that if you have the same sections in your config files, the last loaded file wins.

  If the file you added does not exist, the testsuite will fail.


#### Custom config data as json or yaml

  Additionally, you can provide configuration data in `json` or `yaml` format to
  every `rake` command like this:

    rake feature:admin cct_config='{"admin_node":{"remote":{"ip":"192.168.199:10"}}}'

  These are merged with the data after all configuration files have been loaded.

#### Turn off the fancy colors!

  If you don't like the colored cucumber output or for some other reason you want to
  have it off, provide a bash variable `nocolors` to the `rake` command:

  `rake feature:admin nocolors=true`


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

  This file contains information and formulations as found on
  [cucumber github wiki](https://github.com/cucumber/cucumber/wiki). 


## Contributing

1. Fork it!
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

