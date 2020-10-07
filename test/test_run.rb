require_relative 'helper'

class TestRun < Minitest::Test
  include Helper

  SUCCEEDS = 'echo gub'.freeze
  FAILS = 'cat scripto_bogus_file 2> /dev/null'.freeze
  BAD_COMMAND = 'this_command_doesnt_exist'.freeze
  SRC = '_scripto_src'.freeze
  DST = '_scripto with spaces'.freeze
  ARGS = [ '-f', SRC, DST ].freeze

  def setup
    super
    File.write(SRC, 'something')
  end

  #
  # basic methods
  #

  def test_run
    Scripto.run("#{SUCCEEDS} > #{SRC}")
    assert_equal('gub', File.read(SRC).strip)
    assert('gub', Scripto.run_capture(SUCCEEDS))
    Scripto.run_quietly(SUCCEEDS)
  end

  def test_run_succeeds?
    assert_succeeds(SUCCEEDS)
    assert_fails(FAILS)
    assert_fails(BAD_COMMAND)
  end

  def test_shellescape
    assert_equal('gub',       Scripto.shellescape('gub'))
    assert_equal('gub\\ zub', Scripto.shellescape('gub zub'))
  end

  # verbosity
  def test_verbose
    Scripto.verbose!
    cmd = "#{SUCCEEDS} > /dev/null"
    assert_output(nil, "#{cmd}\n") do
      Scripto.run(cmd)
    end
  end

  # commands that fail
  def test_failures
    assert_raises(Scripto::RunCommands::Error) { Scripto.run(BAD_COMMAND) }
    assert_raises(Scripto::RunCommands::Error) { Scripto.run_capture(BAD_COMMAND) }
    assert_raises(Scripto::RunCommands::Error) { Scripto.run(FAILS) }
    assert_raises(Scripto::RunCommands::Error) { Scripto.run_capture(FAILS) }
  end

  #
  # args
  #

  def test_run_args
    # make sure SRC is copied to DST in all cases
    assert_cp { Scripto.run('cp', ARGS) }
    assert_cp { Scripto.run_quietly('cp', ARGS) }
    assert_cp { assert_succeeds('cp', ARGS) }
  end

  def test_capture_escaping
    tricky = "\"'!tricky!'\""
    assert_equal("#{tricky} #{tricky}\n", Scripto.run_capture('echo', [ tricky, tricky ]))
  end

  def test_args_succeeds_fails
    assert_fails(BAD_COMMAND, ARGS)
  end

  # is output escaped properly with verbose?
  def test_args_verbose
    Scripto.verbose!
    assert_output(nil, "cp -f #{SRC} #{DST.gsub(' ', '\\ ')}\n") do
      Scripto.run('cp', ARGS)
    end
  end

  protected

  def assert_cp
    File.unlink(DST) if File.exist?(DST)
    yield
    assert_equal(File.read(SRC), File.read(DST))
    File.unlink(DST)
  end

  def assert_succeeds(command, args = nil)
    assert_equal(true,  Scripto.run_succeeds?(command, args))
    assert_equal(false, Scripto.run_fails?(command, args))
  end

  def assert_fails(command, args = nil)
    assert_equal(false, Scripto.run_succeeds?(command, args))
    assert_equal(true,  Scripto.run_fails?(command, args))
  end
end
