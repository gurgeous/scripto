module Scripto
  # A convenient superclass for using Scripto. Just subclass Main and you have
  # access to all the Scripto goodies.
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