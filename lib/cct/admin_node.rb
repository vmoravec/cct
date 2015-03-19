module Cct
  class AdminNode
    def initialize
      @crowbar = CrowbarCli.new
    end

    def detect!
    end

    def validate!
    end
  end
end
