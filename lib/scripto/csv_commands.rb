require "csv"
require "ostruct"
require "zlib"

module Scripto
  module CsvCommands
    def csv_read(path)
      lines = if path =~ /\.gz$/
        Zlib::GzipReader.open(path) do |f|
          CSV.new(f).read
        end
      else
        CSV.read(path)
      end
      keys = lines.shift.map(&:to_sym)
      klass = Struct.new(*keys)
      lines.map { |i| klass.new(*i) }
    end

    # write rows to path as CSV
    def csv_write(path, rows, cols: nil)
      begin
        tmp = "/tmp/_scripto_csv.csv"
        CSV.open(tmp, "wb") { |f| csv_write0(f, rows, cols: cols) }
        mv(tmp, path)
      ensure
        rm_if_necessary(tmp)
      end
    end

    def csv_to_stdout(rows, cols: nil)
      CSV($stdout) { |f| csv_write0(f, rows, cols: cols) }
    end

    def csv_to_s(rows, cols: nil)
      string = ""
      f = CSV.new(StringIO.new(string))
      csv_write0(f, rows, cols: cols)
      string
    end

    protected

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