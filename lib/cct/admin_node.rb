module Cct
  class AdminNode
    def initialize
      @crowbar = CrowbarCli.new
    end

    def detect!
    end

    def validate!
      true
    end
  end
end
