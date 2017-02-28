require_relative "helper"

class TestFile < Minitest::Test
  include Helper

  DIR = "dir"
  SRC, DST = "src.txt", "dst.txt"
  SRC2, DST2 = "src2.txt", "dst2.txt"

  def setup
    super
    File.write(SRC, "something")
    File.write(SRC2, "another thing")
  end

  #
  # basics
  #

  def test_mkdir
    Scripto.mkdir(DIR)
    assert(File.directory?(DIR))
  end

  def test_mkdir_mode
    Scripto.mkdir(DIR, mode: 0644)
    assert_equal(0644, File.stat(DIR).mode & 0644)
  end

  def test_cp
    Scripto.cp(SRC, DST)
    assert_equal(File.read(SRC), File.read(DST))
  end

  def test_cp_mode
    Scripto.cp(SRC, DST, mode: 0644)
    assert_equal(0644, File.stat(DST).mode & 0644)
  end

  def test_cp_mkdir
    in_dir = "#{DIR}/in_dir"
    Scripto.cp(SRC, in_dir, mkdir: true)
    assert_equal(File.read(SRC), File.read(in_dir))
  end

  def test_mv
    Scripto.mv(SRC, DST)
    assert_equal("something", File.read(DST))
  end

  def test_mv_mkdir
    in_dir = "#{DIR}/in_dir"
    Scripto.mv(SRC, in_dir, mkdir: true)
    assert_equal("something", File.read(in_dir))
  end

  def test_ln
    Scripto.ln(SRC, DST)
    assert_equal(SRC, File.readlink(DST))
  end

  def test_rm
    Scripto.rm(SRC)
    assert(!File.exist?(SRC))
    Scripto.rm("this_file_doesnt_exist") # shouldn't complain
  end

  #
  # if necessary (this is useful for printing)
  #

  def test_if_necessary
    # should return true
    assert Scripto.mkdir_if_necessary(DIR)
    assert Scripto.cp_if_necessary(SRC, DST)
    assert Scripto.ln_if_necessary(SRC, DST2)

    assert(File.directory?(DIR))
    assert_equal(File.read(SRC), File.read(DST))
    assert_equal(SRC, File.readlink(DST2))

    # should be silent
    assert_fu_output(nil, "") do
      assert_nil Scripto.mkdir_if_necessary(DIR)
      assert_nil Scripto.cp_if_necessary(SRC, DST)
      assert_nil Scripto.ln_if_necessary(SRC, DST2)
    end
  end

  def test_cp_if_necessary_differs
    File.write(DST, "this is different")
    assert_fu_output(nil, "cp -rp #{SRC} #{DST}\n") do
      assert Scripto.cp_if_necessary(SRC, DST)
    end
  end

  def test_ln_if_necessary_differs
    File.symlink(SRC2, DST)
    assert_fu_output(nil, "rm -f #{DST}\nln -sf #{SRC} #{DST}\n") do
      assert Scripto.ln_if_necessary(SRC, DST)
      assert_equal(SRC, File.readlink(DST))
    end
  end

  def test_chmod
    Scripto.chmod(SRC, 0644)
    assert_equal(0644, File.stat(SRC).mode & 0644)
  end

  def test_rm_and_mkdir
    Dir.mkdir(DIR)
    File.write("#{DIR}/file", "this is a test")
    assert Dir["#{DIR}/*"].length == 1
    Scripto.rm_and_mkdir(DIR)
    assert Dir["#{DIR}/*"].length == 0
  end

  def test_copy_metadata
    File.chmod(0644, SRC)
    File.utime(1234, 5678, SRC)
    Scripto.copy_metadata(SRC, SRC2)
    assert_equal(0644, File.stat(SRC2).mode & 0644)
    assert_equal(1234, File.stat(SRC2).atime.to_i)
    assert_equal(5678, File.stat(SRC2).mtime.to_i)
  end

  #
  # chown rests - must be root
  #

  def test_mkdir_owner
    skip if !root?
    Scripto.mkdir(DIR, owner: "nobody")
    assert(Etc.getpwnam("nobody").uid, File.stat(DIR).uid)
  end

  def test_cp_owner
    skip if !root?
    Scripto.cp(SRC, DST, owner: "nobody")
    assert(Etc.getpwnam("nobody").uid, File.stat(DST).uid)
  end

  def test_chown
    skip if !root?
    Scripto.chown(SRC, "nobody")
    assert(Etc.getpwnam("nobody").uid, File.stat(SRC).uid)
  end

  #
  # verbosity
  #

  def test_mkdir_verbose
    assert_fu_output(nil, "mkdir -p #{DIR}\n") do
      Scripto.mkdir(DIR)
    end
  end

  def test_cp_verbose
    assert_fu_output(nil, "cp -rp #{SRC} #{DST}\n") do
      Scripto.cp(SRC, DST)
    end
  end

  def test_mv_verbose
    assert_fu_output(nil, "mv #{SRC} #{DST}\n") do
      Scripto.mv(SRC, DST)
    end
  end

  def test_ln_verbose
    assert_fu_output(nil, "ln -sf #{SRC} #{DST}\n") do
      Scripto.ln(SRC, DST)
    end
  end

  def test_rm_verbose
    assert_fu_output(nil, "rm -f #{SRC}\n") do
      Scripto.rm(SRC)
    end
  end

  protected

  def root?
    if !defined?(@root)
      @root = `whoami`.strip == "root"
    end
    @root
  end

  def assert_fu_output(stdout = nil, stderr = nil, &block)
    Scripto.verbose!
    assert_output(stdout, stderr) do
      # FileUtils squirrels this away so we have to set it manually
      FileUtils.instance_eval("@fileutils_output = $stderr")
      yield
    end
  end
end