require "scripto/csv_commands"
require "scripto/file_commands"
require "scripto/misc_commands"
require "scripto/print_commands"
require "scripto/run_commands"
require "scripto/version"
require "scripto/main"

module Scripto
  extend CsvCommands
  extend FileCommands
  extend MiscCommands
  extend PrintCommands
  extend RunCommands
end
