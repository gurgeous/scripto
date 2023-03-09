require "scripto/csv_commands"
require "scripto/file_commands"
require "scripto/log_commands"
require "scripto/misc_commands"
require "scripto/run_commands"
require "scripto/version"
require "scripto/main"

module Scripto
  extend CsvCommands
  extend FileCommands
  extend LogCommands
  extend MiscCommands
  extend RunCommands
end
