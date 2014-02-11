require "fileutils"
require "minitest/autorun"
require "minitest/pride"

$LOAD_PATH << File.expand_path("../../lib", __FILE__)
require "scripto"

module Helper
  TMP_DIR = "/tmp/_scripto_test"

  # attr_accessor :main

  def setup
    # self.main = Scripto::Main.new
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