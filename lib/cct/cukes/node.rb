module Cct
  module Node
    attr_reader :admin

    def initialize
      @admin = false
    end

    alias_method :admin?, :admin
  end
end


