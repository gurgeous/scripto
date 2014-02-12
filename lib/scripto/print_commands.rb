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

    def vbanner(str = nil)
      banner(str) if verbose?
    end

    def vputs(str = nil)
      $stderr.puts(str) if verbose?
    end

    def vprintf(str, *args)
      $stderr.printf(str, *args) if verbose?
    end

    def banner(str, color: GREEN)
      now = Time.new.strftime("%H:%M:%S")
      s = "#{str} ".ljust(72, " ")
      $stderr.puts "#{color}[#{now}] #{s}#{RESET}"
    end

    def warning(str)
      banner("Warning: #{str}", color: YELLOW)
    end

    def fatal(str)
      banner(str, color: RED)
      exit(1)
    end
  end
end