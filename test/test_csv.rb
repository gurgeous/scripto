require_relative 'helper'

class TestCsv < Minitest::Test
  include Helper

  FILE = 'test.csv'.freeze

  ROWS = [ { a: '1', b: '2', c: '3' }, { a: '4', b: '5', c: '6' } ].freeze
  ROWS_EXP = "a,b,c\n1,2,3\n4,5,6\n".freeze
  ROWS_REVERSED_EXP = "c,b,a\n3,2,1\n6,5,4\n".freeze

  def test_types
    assert_equal(ROWS_EXP, Scripto.csv_to_s(ROWS))
    assert_equal(ROWS_EXP, Scripto.csv_to_s(structs))
    assert_equal(ROWS_EXP, Scripto.csv_to_s(ostructs))
  end

  def test_cols
    assert_equal(ROWS_REVERSED_EXP, Scripto.csv_to_s(ROWS,     cols: %i[c b a]))
    assert_equal(ROWS_REVERSED_EXP, Scripto.csv_to_s(structs,  cols: %i[c b a]))
    assert_equal(ROWS_REVERSED_EXP, Scripto.csv_to_s(ostructs, cols: %i[c b a]))
  end

  def test_csv_stdout
    assert_output(ROWS_EXP) { Scripto.csv_to_stdout(ROWS) }
  end

  def test_csv_read_write
    Scripto.csv_write(FILE, ROWS)
    assert_equal(ROWS_EXP, File.read(FILE))
    assert_equal(ROWS, Scripto.csv_read(FILE).map(&:to_h))
  end

  def test_gz
    Scripto.csv_write(FILE, ROWS)
    Scripto.run("gzip #{FILE}")
    assert_equal(ROWS, Scripto.csv_read("#{FILE}.gz").map(&:to_h))
  end

  def test_bom
    assert_equal('apple', Scripto.csv_read(write_bom).first.fruit)
  end

  def test_gz_with_bom
    skip # this doesn't work yet
    path = write_bom
    Scripto.run("gzip #{path}")
    assert_equal('apple', Scripto.csv_read("#{path}.gz").first.fruit)
  end

  protected

  def structs
    klass = Struct.new(*ROWS.first.keys)
    ROWS.map { |i| klass.new(*i.values) }
  end

  def ostructs
    ROWS.map { |i| OpenStruct.new(i) }
  end

  def write_bom
    CSV.open(FILE, 'w') do |csv|
      csv.to_io.write "\uFEFF" # bom
      csv << %w[fruit]
      csv << %w[apple]
    end
    FILE
  end
end
