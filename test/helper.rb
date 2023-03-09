require "fileutils"
require "minitest/autorun"
require "minitest/pride"
require "mocha/minitest"

$LOAD_PATH << File.expand_path("../lib", __dir__)
require "scripto"

module Helper
  TMP_DIR = "/tmp/_scripto_test".freeze

  def setup
    reset_scripto
    @pwd = Dir.pwd
    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)
    Dir.chdir(TMP_DIR)
  end

  def teardown
    Dir.chdir(@pwd)
    FileUtils.rm_rf(TMP_DIR)
  end

  # Clear Scripto instance variables so we can start fresh.
  def reset_scripto
    %i[@log_with_color @logger @options].each do
      if Scripto.instance_variable_defined?(_1)
        Scripto.remove_instance_variable(_1)
      end
    end
  end
end
