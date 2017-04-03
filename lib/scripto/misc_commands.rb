require "digest/md5"
require "etc"

module Scripto
  module MiscCommands
    BASE_62 = ("0".."9").to_a + ("A".."Z").to_a + ("a".."z").to_a

    # Who is the current user?
    def whoami
      @scripto_whoami ||= Etc.getpwuid(Process.uid).name
    end

    # Return true if the current user is "root".
    def root?
      whoami == "root"
    end

    # Return the md5 checksum for the file at +path+.
    def md5_file(path)
      File.open(path) do |f|
        digest, buf = Digest::MD5.new, ""
        while f.read(4096, buf)
          digest.update(buf)
        end
        digest.hexdigest
      end
    end

    # Return the md5 checksum for +str+.
    def md5_string(str)
      Digest::MD5.hexdigest(str.to_s)
    end

    # Ask the user a question via stderr, then return true if they enter YES,
    # yes, y, etc.
    def prompt?(question)
      $stderr.write("#{question} (y/n) ")
      $stderr.flush
      $stdin.gets =~ /^y/i
    end

    # Return a random alphanumeric string of length +len+.
    def random_string(len)
      (1..len).map { BASE_62.sample }.join
    end
  end
end
