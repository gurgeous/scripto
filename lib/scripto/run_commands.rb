require "english"
require "shellwords"

module Scripto
	module RunCommands
    class Error < StandardError ; end

    def run(command, args = nil)
      cmd = CommandLine.new(command, args)
      vputs(cmd)
      cmd.run
    end

    def run_capture(command, args = nil)
      CommandLine.new(command, args).capture
    end

    def run_quietly(command, args = nil)
      cmd = CommandLine.new(command, args)
      run("#{cmd} > /dev/null 2> /dev/null")
    end

    def run_succeeds?(command, args = nil)
      begin
        run_quietly(command, args)
        true
      rescue Error
        false
      end
    end

    def run_fails?(command, args = nil)
      !run_succeeds?(command, args)
    end

    def shellescape(s)
      Shellwords.escape(s)
    end

    protected

    class CommandLine
      attr_accessor :command, :args

      def initialize(command, args)
        self.command = command
        self.args = if args
          args.map(&:to_s)
        else
          [ ]
        end
      end

      def run
        system(command, *args)
        raise!($CHILD_STATUS) if $CHILD_STATUS != 0
      end

      def capture
        begin
          captured = `#{to_s}`
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
        if args.length > 0
          escaped = args.map { |i| Shellwords.escape(i) }
          "#{command} #{escaped.join(" ")}"
        else
          command
        end
      end
    end
  end
end