module Cct
  class Nodes
    attr_reader :nodes
    private :nodes

    def initialize crowbar_api
      @crowbar = crowbar_api
      @loaded = false
      @nodes = Array.new
    end

    def loaded?
      @loaded
    end

    def load!
      return if loaded?

      load_nodes!
      nodes
    end

    def inspect
      nodes.inspect
    end

    private

    def load_nodes!
      crowbar.nodes
      @loaded = true
    end
  end
end
