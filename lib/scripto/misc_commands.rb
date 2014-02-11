require "digest/md5"
require "etc"

module Scripto
  module MiscCommands
    BASE_62 = ("0".."9").to_a + ("A".."Z").to_a + ("a".."z").to_a

    def whoami
      @scripto_whoami ||= Etc.getpwuid(Process.uid).name
    end

    def root?
      whoami == "root"
    end

    def md5_file(path)
      File.open(path) do |f|
        digest, buf = Digest::MD5.new, ""
        while f.read(4096, buf)
          digest.update(buf)
        end
        digest.hexdigest
      end
    end

    def md5_string(s)
      Digest::MD5.hexdigest(s.to_s)
    end

    def prompt?(question)
      $stderr.write("#{question} (y/n) ")
      $stderr.flush
      $stdin.gets =~ /^y/i
    end

    def random_string(len)
      (1..len).map { BASE_62.sample }.join
    end
  end
end