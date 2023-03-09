module Scripto
  module PrintCommands
    RESET = "\e[0m".freeze
    GREEN = "\e[1;37;42m".freeze
    YELLOW = "\e[1;37;43m".freeze
    RED = "\e[1;37;41m".freeze

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

    # Print a colored banner, but only if #verbose?.
    def vbanner(str = nil)
      banner(str) if verbose?
    end

    # Puts, but only if #verbose?.
    def vputs(str = nil)
      puts str if verbose?
    end

    # Printf, but only if #verbose?.
    def vprintf(str, *args)
      printf(str, *args) if verbose?
    end

    # Print a colored banner in green.
    def banner(str, color: GREEN)
      s = "#{str} ".ljust(72, " ")
      s = "[#{Time.new.strftime("%H:%M:%S")}] #{s}"
      s = "#{color}#{s}#{RESET}" if $stdout.tty?
      puts s
    end

    # Print a yellow warning banner.
    def warning(str)
      banner("Warning: #{str}", color: YELLOW)
    end

    # Print a red error banner, then exit.
    def fatal(str)
      banner(str, color: RED)
      exit(1)
    end
  end
end
