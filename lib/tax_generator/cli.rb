require_relative './all'
module TaxGenerator
  # this is the class that will be invoked from terminal , and willl use the invoke task as the primary function.
  class CLI
    # method used to start
    #
    # @return [void]
    #
    # @api public
    def self.start
      TaxGenerator::Application.new.run
    end
  end
end
