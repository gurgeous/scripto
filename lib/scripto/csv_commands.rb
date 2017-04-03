require "csv"
require "tempfile"
require "zlib"

module Scripto
  module CsvCommands
    # Read a csv from +path+. Returns an array of Structs, using the keys from
    # the csv header row.
    def csv_read(path)
      lines = begin
        if path =~ /\.gz$/
          Zlib::GzipReader.open(path) do |f|
            CSV.new(f).read
          end
        else
          CSV.read(path)
        end
      end
      keys = lines.shift.map(&:to_sym)
      klass = Struct.new(*keys)
      lines.map { |i| klass.new(*i) }
    end

    # Write +rows+ to +path+ as csv. Rows can be an array of hashes, Structs,
    # OpenStructs, or anything else that responds to to_h. The keys from the
    # first row are used as the csv header. If +cols+ is specified, it will be
    # used as the column keys instead.
    def csv_write(path, rows, cols: nil)
      atomic_write(path) do |tmp|
        CSV.open(tmp.path, "wb") { |f| csv_write0(f, rows, cols: cols) }
      end
    end

    # Write +rows+ to $stdout as a csv. Similar to csv_write.
    def csv_to_stdout(rows, cols: nil)
      CSV($stdout) { |f| csv_write0(f, rows, cols: cols) }
    end

    # Returns a string containing +rows+ as a csv. Similar to csv_write.
    def csv_to_s(rows, cols: nil)
      string = ""
      f = CSV.new(StringIO.new(string))
      csv_write0(f, rows, cols: cols)
      string
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
        csv << cols.map { |i| row[i] }
      end
    end
  end
end
