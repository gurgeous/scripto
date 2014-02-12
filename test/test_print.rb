require_relative "helper"

class TestPrint < Minitest::Test
  include Helper

  def test_verbose?
    assert(!Scripto.verbose?)
    Scripto.verbose!
    assert(Scripto.verbose?)
  end

  def test_quiet
    assert_silent { Scripto.vbanner "gub" }
    assert_silent { Scripto.vprintf("gub %d", 123) }
    assert_silent { Scripto.vputs "gub" }
  end

  def test_loud
    Scripto.verbose!
    assert_output(nil, /gub/) { Scripto.vbanner "gub" }
    assert_output(nil, /gub/) { Scripto.vprintf("zub %s", "gub") }
    assert_output(nil, /gub/) { Scripto.vputs "gub" }
  end

  def test_warning
    assert_output(nil, /gub/) { Scripto.warning "gub" }
  end
end