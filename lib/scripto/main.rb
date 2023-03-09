module Scripto
  # A convenient superclass for using Scripto. Just subclass Main and you have
  # access to all the Scripto goodies.
  class Main
    include CsvCommands
    include FileCommands
    include MiscCommands
    include LogCommands
    include RunCommands

    def initialize(options = {})
      self.options = options
    end
  end
end
