module Scripto
  module PrintCommands
    RESET   = "\e[0m".freeze
    GREEN   = "\e[1;37;42m".freeze
    YELLOW  = "\e[1;37;43m".freeze
    RED     = "\e[1;37;41m".freeze

    attr_accessor :verbose

    # Is verbose mode turned on?
    def verbose?
      !!@verbose
    end

    # Turn on verbose mode. #vbanner, #vputs and #vprintf will start printing
    # now, and file ops will be printed too.
    def verbose!
      @verbose = true
    end

    # Print a colored banner to $stderr, but only if #verbose?.
    def vbanner(str = nil)
      banner(str) if verbose?
    end

    # Puts to $stderr, but only if #verbose?.
    def vputs(str = nil)
      $stderr.puts(str) if verbose?
    end

    # Printf to $stderr, but only if #verbose?.
    def vprintf(str, *args)
      $stderr.printf(str, *args) if verbose?
    end

    # Print a colored banner to $stderr in green.
    def banner(str, color: GREEN)
      now = Time.new.strftime('%H:%M:%S')
      s = "#{str} ".ljust(72, ' ')
      $stderr.puts "#{color}[#{now}] #{s}#{RESET}"
    end

    # Print a yellow warning banner to $stderr.
    def warning(str)
      banner("Warning: #{str}", color: YELLOW)
    end

    # Print a red error banner to $stderr, then exit.
    def fatal(str)
      banner(str, color: RED)
      exit(1)
    end
  end
end
