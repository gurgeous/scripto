require_relative 'helper'

class TestMisc < Minitest::Test
  include Helper

  def test_whoami
    assert_equal(`whoami`.strip, Scripto.whoami)
  end

  def test_root?
    assert_equal(`whoami`.strip == 'root', Scripto.root?)
  end

  def test_md5_string
    assert_equal('ba73632f801ac2c72d78134722f2cb84', Scripto.md5_string('gub'))
  end

  def test_md5_file
    File.write('test.txt', 'gub')
    assert_equal('ba73632f801ac2c72d78134722f2cb84', Scripto.md5_file('test.txt'))
  end

  def test_prompt?
    with_fake_stdin('YES') do
      assert_output(nil, 'question (y/n) ') do
        assert Scripto.prompt?('question')
      end
    end
    with_fake_stdin('y') do
      assert_output(nil, 'question (y/n) ') do
        assert Scripto.prompt?('question')
      end
    end
    with_fake_stdin('no') do
      assert_output(nil, 'question (y/n) ') do
        assert !Scripto.prompt?('question')
      end
    end
  end

  protected

  def with_fake_stdin(str)
    old_stdin = $stdin
    begin
      $stdin = StringIO.new(str)
      $stdin.rewind
      yield
    ensure
      $stdin = old_stdin
    end
  end
end
