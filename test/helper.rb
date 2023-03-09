require "fileutils"
require "minitest/autorun"
require "minitest/pride"
require "ostruct"

$LOAD_PATH << File.expand_path("../lib", __dir__)
require "scripto"

module Helper
  TMP_DIR = "/tmp/_scripto_test".freeze

  def setup
    FileUtils.rm_rf(TMP_DIR)
    FileUtils.mkdir_p(TMP_DIR)
    @pwd = Dir.pwd
    Dir.chdir(TMP_DIR)
    Scripto.verbose = false
  end

  def teardown
    FileUtils.rm_rf(TMP_DIR)
    Dir.chdir(@pwd)
  end
end
