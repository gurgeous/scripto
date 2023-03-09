require "English"
require "shellwords"

module Scripto
  module RunCommands
    # The error thrown by #run, #run_capture and #run_quietly on failure.
    class Error < StandardError
    end

    # Run an external command. Raise Error if something goes wrong. The
    # command will be echoed if verbose?.
    #
    # Usage is similar to Kernel#system. If +args+ is nil, +command+ will be
    # passed to the shell. If +args+ are included, the +command+ and +args+
    # will be run directly without the shell.
    def run(command, args = nil)
      cmd = CommandLine.new(command, args)
      vputs(cmd)
      cmd.run
    end

    # Run a command and capture the output like backticks. See #run
    # for details.
    def run_capture(command, args = nil)
      CommandLine.new(command, args).capture
    end

    # Run a command and suppress output by redirecting to /dev/null. See #run
    # for details.
    def run_quietly(command, args = nil)
      cmd = CommandLine.new(command, args)
      run("#{cmd} > /dev/null 2> /dev/null")
    end

    # Returns true if the command succeeds. See #run for details.
    def run_succeeds?(command, args = nil)
      run_quietly(command, args)
      true
    rescue Error
      false
    end

    # Returns true if the command fails. See #run for details.
    def run_fails?(command, args = nil)
      !run_succeeds?(command, args)
    end

    # Escape str if necessary. Useful for passing arguments to a shell.
    def shellescape(str)
      Shellwords.escape(str)
    end

    # :nodoc:
    class CommandLine
      attr_accessor :command, :args

      def initialize(command, args)
        self.command = command
        self.args = begin
          if args
            args.map(&:to_s)
          else
            []
          end
        end
      end

      def run
        system(command, *args)
        raise!($CHILD_STATUS) if $CHILD_STATUS != 0
      end

      def capture
        begin
          captured = `#{self}`
        rescue Errno::ENOENT
          raise Error, "#{self} failed : ENOENT (No such file or directory)"
        end
        raise!($CHILD_STATUS) if $CHILD_STATUS != 0
        captured
      end

      def raise!(status)
        if status.termsig == Signal.list["INT"]
          raise "#{self} interrupted"
        end

        raise Error, "#{self} failed : #{status.to_i / 256}"
      end

      def to_s
        if !args.empty?
          escaped = args.map { Shellwords.escape(_1) }
          "#{command} #{escaped.join(" ")}"
        else
          command
        end
      end
    end
  end
end
