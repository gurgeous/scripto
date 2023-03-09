require "csv"
require "tempfile"
require "zlib"

module Scripto
  module CsvCommands
    # Read a csv from +path+. Returns an array of Structs, using the keys from
    # the csv header row.
    def csv_read(path)
      rows = if /\.gz$/.match?(path)
        Zlib::GzipReader.open(path) do
          CSV.new(_1).read
        end
      else
        CSV.read(path, encoding: "bom|utf-8")
      end

      keys = rows.shift.map(&:to_sym)
      klass = Struct.new(*keys)
      rows.map { klass.new(*_1) }
    end

    # Write +rows+ to +path+ as csv. Rows can be an array of hashes, Structs,
    # OpenStructs, or anything else that responds to to_h. The keys from the
    # first row are used as the csv header. If +cols+ is specified, it will be
    # used as the column keys instead.
    def csv_write(path, rows, cols: nil)
      atomic_write(path) do |tmp|
        CSV.open(tmp.path, "wb") { csv_write0(_1, rows, cols:) }
      end
    end

    # Write +rows+ to $stdout as a csv. Similar to csv_write.
    def csv_to_stdout(rows, cols: nil)
      CSV($stdout) { csv_write0(_1, rows, cols:) }
    end

    # Returns a string containing +rows+ as a csv. Similar to csv_write.
    def csv_to_s(rows, cols: nil)
      "".tap do
        f = CSV.new(StringIO.new(_1))
        csv_write0(f, rows, cols:)
      end
    end

    protected

    # :nodoc:
    def csv_write0(csv, rows, cols: nil)
      # cols
      cols ||= rows.first.to_h.keys
      csv << cols

      # rows
      rows.each do |row|
        row = row.to_h
        csv << cols.map { row[_1] }
      end
    end
  end
end
