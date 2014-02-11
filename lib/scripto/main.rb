module Scripto
  class Main
    include CsvCommands
    include FileCommands
    include MiscCommands
    include PrintCommands
    include RunCommands

    attr_accessor :options

    def initialize(options = {})
      self.options = options
      self.verbose = options[:verbose]
    end
  end
end