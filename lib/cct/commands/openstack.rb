require "csv"

module Cct
  module Commands
    # Is included into controller node and provides method #openstack as namespace
    # for openstack client commands
    module Openstack
      # @return [Openstack] object that provides the openstack client commands
      def openstack
        @openstack ||= Openstack::Client.new(self)
      end

      # Proxy object for accessing all openstack client commands.
      # If a new command is added, e.g. in lib/cct/commands/openstack/new_command.rb,
      # don't forget to add it also into the #initialize method including the attr_readers
      class Client
        COMMAND = "openstack"

        # @return [Openstack::Image] for accessing openstack.image subcommands
        attr_reader :image
        attr_reader :user
        attr_reader :project
        attr_reader :network
        attr_reader :role
        attr_reader :keypair
        attr_reader :security_group
        attr_reader :ip_floating
        attr_reader :flavor
        attr_reader :server

        # @param [Cct::Node] as the receiver for the openstack client
        def initialize node
          @image = Openstack::Image.new(node)
          @user = Openstack::User.new(node)
          @project = Openstack::Project.new(node)
          @network = Openstack::Network.new(node)
          @role = Openstack::Role.new(node)
          @keypair = Openstack::Keypair.new(node)
          @security_group = Openstack::SecurityGroup.new(node)
          @ip_floating = Openstack::IpFloating.new(node)
          @flavor = Openstack::Flavor.new(node)
          @server = Openstack::Server.new(node)
        end

        def actions
          public_methods.sort - Object.methods
        end
      end

      # Parent class to inherit from for all openstack client commands
      # @example Implementation of openstack.user subcommands
      #
      # class User < Command
      #   self.command = "user" # This will set the namespace: openstack.user
      #
      #   # Access with `control_node.openstack.user.create("Mozart", password: "Wien")`
      #   def create name, options={}
      #     super do |params|
      #       params.add :optional, password: "--password"
      #       params.add :optional, email:    "--email"
      #       params.add :optional, project:  "--project"
      #       params.add :optional, enable:   "--enable",  param_type: :switch
      #       params.add :optional, disable:  "--disable", param_type: :switch
      #     end
      #   end
      # end
      class Command
        class << self
          attr_accessor :command
          attr_accessor :subcommand
        end

        attr_reader :node, :log, :params, :command, :subcommand, :parent

        def initialize node, parent=nil
          @node = node
          @log = node.log
          @params = Params.new
          #@command = self.class.command
          @command =
          if self.class.command.is_a?(Array)
            self.class.command.join(" ")
          else
            self.class.command
          end
          @subcommand = self.class.subcommand.new(node, self) if self.class.subcommand
          @parent = parent
        end

        def exec! subcommand, *params
          parent_command = (parent && "#{parent.command} ") || ""
          node.exec!(
            Openstack::Client::COMMAND,
            parent_command << command,
            subcommand,
            *params,
            "--insecure") # yes, we ignore server certificates in SSL enabled cloud
        end

        def create name, options={}
          params.clear
          yield params if block_given?
          all_params = ["create", name, "--format=shell"].concat(params.extract!(options))
          result = exec!(all_params).output
          options[:dont_format_output] ? result : OpenStruct.new(shell_parse(result))
        end

        def add options={}
          params.clear
          yield params if block_given?
          all_params = ["add #{options[:args].join(" ")} "].concat(params.extract!(options))
          result = exec!(all_params.join(" ")).output
          OpenStruct.new(shell_parse(result))
        end

        def set name, options={}
          params.clear
          yield params
          all_params = ["set", name].concat(params.extract!(options))
          OpenStruct.new(shell_parse(exec!(all_params).output))
        end

        def delete id_or_name, options={}
          params.clear
          yield params if block_given?
          all_params = ["delete", id_or_name].concat(params.extract!(options))
          exec!(all_params)
        end

        def list options=[]
          params.clear
          extended = options.last.is_a?(Hash) ? options.pop : {}
          row = extended[:keys] || Struct.new(:id, :name)
          result = exec!("list #{extended[:args]}", "--format=csv", extended[:columns], options).output
          csv_parse(result).map do |csv_row|
            row.new(*csv_row)
          end
        end

        def show id_or_name
          params.clear
          OpenStruct.new(shell_parse(exec!("show", id_or_name, "--format=shell").output))
        end

        def exist? id_or_name
          show(id_or_name) and return true
        rescue Cct::RemoteCommandFailed
          return false
        end

        def custom *args
          options = args.last.is_a?(Hash) ? args.pop : {}
          command = args.concat(params.extract!(options))
          result = exec!(command)
          case options[:format]
          when :csv
            csv_parse(result.output).flatten
          when :shell
            shell_parse(result.output)
          else
            result.output
          end
        end

        private

        def columns names
          {
            keys: Struct.new(*names.keys),
            columns: names.values.map {|column_name| "-c \'#{column_name}\' " }.join
          }
        end

        def csv_parse csv_data, header: false
          result = CSV.parse(csv_data)
          header ? result : result.drop(1)
        end

        def shell_parse shell_data
          shell_data.gsub("\"", "").split("\n").reduce({}) do |result, shell_pair|
            next result if shell_pair.empty?
            attribute, value = shell_pair.split("=")
            result[attribute] = value
            result
          end
        end

        def method_missing name, *args, &block
          super unless subcommand && name.to_s == subcommand.class.command

          subcommand
        end

        class Params
          attr_reader :mandatory, :optional, :properties, :shell

          def initialize
            @mandatory = []
            @optional = []
            @properties = []
            @shell = []
          end

          def add type=:mandatory, params
            case type
            when :mandatory
              mandatory.push(params)
            when :optional
              optional.push(params)
            when :property, :properties
              properties.push(params)
            else
              raise "Type '#{type}' for parameters not allowed"
            end
          end

          def extract! options
            extract(:mandatory, options)
            extract(:optional, options)
            extract(:properties, options)
            shell
          end

          def clear
            mandatory.clear
            optional.clear
            properties.clear
            shell.clear
          end

          private

          def extract type, options
            params = filter_params(type)
            params.each do |param|
              param_type = param.delete(:param_type)
              shell.push(options[:properties]) if param_type == :properties

              param.each_pair do |key, value|
                if !options[key]
                  next if type == :optional || type == :properties
                  raise "Parameter '#{key}' is mandatory" if type == :mandatory
                end

                case param_type
                when :switch
                  shell.push(value)
                else
                  if type == :properties
                    shell.push("--property #{value}=#{options[key]}") if options[key]
                  else
                    shell.push("#{value}=\"#{options[key]}\"")
                  end
                end
              end
            end
          end

          def filter_params type
            case type
              when :mandatory  then mandatory
              when :optional   then optional
              when :properties then properties
            end
          end

        end
      end
    end
  end
end

require 'cct/commands/openstack/image'
require 'cct/commands/openstack/user'
require 'cct/commands/openstack/project'
require 'cct/commands/openstack/network'
require 'cct/commands/openstack/role'
require 'cct/commands/openstack/keypair'
require 'cct/commands/openstack/security_rule'
require 'cct/commands/openstack/security_group'
require 'cct/commands/openstack/ip_floating'
require 'cct/commands/openstack/flavor'
require 'cct/commands/openstack/server'

