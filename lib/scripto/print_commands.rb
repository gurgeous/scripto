module Scripto
  module PrintCommands
    RESET   = "\e[0m"
    GREEN   = "\e[1;37;42m"
    YELLOW  = "\e[1;37;43m"
    RED     = "\e[1;37;41m"

    attr_accessor :verbose

    def verbose?
      !!@verbose
    end

    def verbose!
      @verbose = true
    end

    def vbanner(s = nil)
      banner(s) if verbose?
    end

    def vputs(s = nil)
      $stderr.puts(s) if verbose?
    end

    def vprintf(s, *args)
      $stderr.printf(s, *args) if verbose?
    end

    def banner(s, color: GREEN)
      now = Time.new.strftime("%H:%M:%S")
      s = "#{s} ".ljust(72, " ")
      $stderr.puts "#{color}[#{now}] #{s}#{RESET}"
    end

    def warning(msg)
      banner("Warning: #{msg}", color: YELLOW)
    end

    def fatal(msg)
      banner(msg, color: RED)
      exit(1)
    end
  end
end