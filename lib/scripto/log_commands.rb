require "logger"

module Scripto
  module LogCommands
    RESET = "\e[0m".freeze
    GREEN = "\e[1;37;42m".freeze
    YELLOW = "\e[1;37;43m".freeze
    RED = "\e[1;37;41m".freeze

    #
    # logger
    #

    # Returns the built-in logger. If none has been set, create a new one
    # wrapped around $stdout. Used by banner/warning/fatal.
    def logger
      @logger ||= begin
        self.log_with_color = $stdout.tty? if !defined?(@log_with_color)
        level = if options[:verbose]
          Logger::DEBUG
        elsif options[:quiet]
          Logger::ERROR
        else
          Logger::INFO
        end
        Logger.new($stdout, level:, formatter: Formatter.new)
      end
    end

    # Set the built-in logger.
    def logger=(value)
      @logger = value
    end

    #
    # options
    #

    # Get options
    def options
      @options ||= {}
    end

    # Set options
    def options=(value)
      @options = value.dup
    end

    # Should we log in verbose mode?
    def verbose?
      logger.level == Logger::DEBUG
    end

    # Should we log in quiet mode?
    def quiet?
      logger.level == Logger::ERROR
    end

    # Set logging to verbose (DEBUG)
    def verbose!
      logger.level = Logger::DEBUG
    end

    # Set logging to quiet (ERROR)
    def quiet!
      logger.level = Logger::ERROR
    end

    # Should we use color? Inferred from $stdout.tty? if not set.
    def log_with_color?
      return @log_with_color if defined?(@log_with_color)
      false
    end

    # Set whether we should use color.
    def log_with_color=(value)
      @log_with_color = value
    end

    #
    # banner/warning/fatal
    #

    # Log a colored banner in green.
    def banner(str, log_level: Logger::INFO, color: GREEN)
      s = "#{str} ".ljust(72, " ")
      s = "[#{Time.new.strftime("%H:%M:%S")}] #{s}"
      s = "#{color}#{s}#{RESET}" if log_with_color?
      logger.add(log_level, s)
      nil
    end

    # Log a yellow warning banner.
    def warning(str)
      banner("Warning: #{str}", log_level: Logger::WARN, color: YELLOW)
    end

    # Log a red error banner, then exit.
    def fatal(str)
      banner(str, log_level: Logger::FATAL, color: RED)
      exit(1)
    end

    # Simple log formatter with no timestamp.
    class Formatter < Logger::Formatter
      def call(_severity, _time, _progname, msg)
        "#{msg}\n"
      end
    end
  end
end
