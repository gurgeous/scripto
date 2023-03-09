require_relative "helper"

class TestLog < Minitest::Test
  include Helper

  def test_global_options
    assert !Scripto.verbose? && !Scripto.quiet?

    Scripto.verbose!
    assert Scripto.verbose? && !Scripto.quiet?

    Scripto.quiet!
    assert !Scripto.verbose? && Scripto.quiet?
  end

  def test_global_logger
    # default
    assert_log("", Scripto.logger) { Scripto.logger.debug "debug" }
    assert_log(/banner/, Scripto.logger) { Scripto.banner "banner" }
    assert_log(/warning/, Scripto.logger) { Scripto.warning "warning" }
    assert_log(/error/, Scripto.logger) { Scripto.logger.error "error" }

    # verbose
    Scripto.verbose!
    assert_log(/debug/, Scripto.logger) { Scripto.logger.debug "debug" }
    assert_log(/banner/, Scripto.logger) { Scripto.banner "banner" }
    assert_log(/warning/, Scripto.logger) { Scripto.warning "warning" }
    assert_log(/error/, Scripto.logger) { Scripto.logger.error "error" }

    # quiet
    Scripto.quiet!
    assert_log("", Scripto.logger) { Scripto.logger.debug "debug" }
    assert_log("", Scripto.logger) { Scripto.banner "banner" }
    assert_log("", Scripto.logger) { Scripto.warning "warning" }
    assert_log(/error/, Scripto.logger) { Scripto.logger.error "error" }
  end

  def test_color
    # default (color)
    reset_scripto
    $stdout.stub(:tty?, true) do
      assert_log(/\e/, Scripto.logger) { Scripto.banner "banner" }
    end

    # pipe (plain)
    reset_scripto
    $stdout.stub(:tty?, false) do
      assert_log(/^[^\e]+$/, Scripto.logger) { Scripto.banner "banner" }
    end

    # custom logger (plain)
    reset_scripto
    Scripto.logger = Logger.new($stdout, formatter: Scripto::LogCommands::Formatter.new)
    assert_log(/^[^\e]+$/, Scripto.logger) { Scripto.banner "banner" }

    # explicit
    reset_scripto
    Scripto.log_with_color = true
    assert_log(/\e/, Scripto.logger) { Scripto.banner "banner" }
    Scripto.log_with_color = false
    assert_log(/^[^\e]+$/, Scripto.logger) { Scripto.banner "banner" }
  end

  def test_main
    # default
    main = Scripto::Main.new
    assert !main.verbose? && !main.quiet?
    assert_log("", main.logger) { main.logger.debug "debug" }
    assert_log(/banner/, main.logger) { main.banner "banner" }
    assert_log(/warning/, main.logger) { main.warning "warning" }
    assert_log(/error/, main.logger) { main.logger.error "error" }

    # verbose
    main = Scripto::Main.new(verbose: true)
    assert main.verbose? && !main.quiet?
    assert_log(/debug/, main.logger) { main.logger.debug "debug" }
    assert_log(/banner/, main.logger) { main.banner "banner" }
    assert_log(/warning/, main.logger) { main.warning "warning" }
    assert_log(/error/, main.logger) { main.logger.error "error" }

    # quiet
    main = Scripto::Main.new(quiet: true)
    assert !main.verbose? && main.quiet?
    assert_log("", main.logger) { main.logger.debug "debug" }
    assert_log("", main.logger) { main.banner "banner" }
    assert_log("", main.logger) { main.warning "warning" }
    assert_log(/error/, main.logger) { main.logger.error "error" }
  end

  protected

  def capture_logger(logger:)
    cap, old = StringIO.new, logger.instance_variable_get(:@logdev)
    begin
      logger.instance_variable_set(:@logdev, cap)
      yield
    ensure
      logger.instance_variable_set(:@logdev, old)
    end
    cap.string
  end

  def assert_log(stdout, logger)
    flunk "assert_output requires a block to capture output." unless block_given?

    out = capture_logger(logger:) { yield }
    meth = (Regexp === stdout) ? :assert_match : :assert_equal
    send(meth, stdout, out)
  rescue Minitest::Assertion
    raise
  rescue => e
    raise UnexpectedError, e
  end
end
