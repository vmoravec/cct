require "csv"

module Cct
  module Commands
    module Openstack
      class Client
        COMMAND = "openstack"

        attr_reader :image
        attr_reader :user

        def initialize node
          @image = Openstack::Image.new(node)
          @user = Openstack::User.new(node)
        end
      end

      def openstack
        @openstack ||= Openstack::Client.new(self)
      end

      module NodeContext
        def self.included client_command
          client_command.extend(ContextMethods)
        end

        attr_reader :node, :log

        def initialize node
          @node = node
          @log  = node.log
        end

        def exec! subcommand, *params
          node.exec!(Openstack::Client::COMMAND, self.class.command, subcommand, *params)
        end

        def csv_parse csv_data, header: false
          result = CSV.parse(csv_data)
          header ? result : result.drop(1)
        end

        def shell_parse shell_data
          shell_data.gsub("\"", "").split("\n").reduce({}) do |result, shell_pair|
            attribute, value = shell_pair.split("=")
            result[attribute] = value
            result
          end
        end

        def optional arg_name, key, params, type: nil
          return "" unless params[key]
          return arg_name if params[key] && type == :switch

          "#{arg_name}=#{params[key]}"
        end

        module ContextMethods
          attr_accessor :command
        end
      end

    end
  end
end

require 'cct/commands/openstack/image'
require 'cct/commands/openstack/user'

