require "etc"
require "fileutils"

module Scripto
  module FileCommands
    def mkdir(dir, owner: nil, mode: nil)
      FileUtils.mkdir_p(dir, verbose: verbose?)
      chown(dir, owner) if owner
      chmod(dir, mode) if mode
    end

    def cp(src, dst, mkdir: false, owner: nil, mode: nil)
      mkdir_if_necessary(File.dirname(dst)) if mkdir
      FileUtils.cp_r(src, dst, preserve: true, verbose: verbose?)
      chown(dst, owner) if owner && !File.symlink?(dst)
      chmod(dst, mode) if mode
    end

    def mv(src, dst, mkdir: false)
      mkdir_if_necessary(File.dirname(dst)) if mkdir
      FileUtils.mv(src, dst, verbose: verbose?)
    end

    def ln(src, dst)
      begin
        FileUtils.ln_sf(src, dst, verbose: verbose?)
      rescue Errno::EEXIST => e
        # It's a race - this can occur because ln_sf removes the old
        # dst, then creates the symlink. Raise if they don't match.
        raise e if !(File.symlink?(dst) && src == File.readlink(dst))
      end
    end

    def rm(file)
      FileUtils.rm_f(file, verbose: verbose?)
    end

    def mkdir_if_necessary(dir, owner: nil, mode: nil)
      if !(File.exists?(dir) || File.symlink?(dir))
        mkdir(dir, owner: owner, mode: mode)
        true
      end
    end

    def cp_if_necessary(src, dst, mkdir: false, owner: nil, mode: nil)
      if !(File.exists?(dst) && FileUtils.compare_file(src, dst))
        cp(src, dst, mkdir: mkdir, owner: owner, mode: mode)
        true
      end
    end

    def ln_if_necessary(src, dst)
      ln = if !File.symlink?(dst)
        true
      elsif File.readlink(dst) != src
        rm(dst)
        true
      end
      if ln
        ln(src, dst)
        true
      end
    end

    def rm_if_necessary(file)
      if File.exists?(file)
        rm(file)
        true
      end
    end

    def chown(file, user)
      # who is the current owner?
      @scripto_uids ||= {}
      @scripto_uids[user] ||= Etc.getpwnam(user).uid
      uid = @scripto_uids[user]
      if File.stat(file).uid != uid
        FileUtils.chown(uid, uid, file, verbose: verbose?)
      end
    end

    def chmod(file, mode)
      if File.stat(file).mode != mode
        FileUtils.chmod(mode, file, verbose: verbose?)
      end
    end

    def rm_and_mkdir(dir)
      raise "don't do this" if dir == ""
      FileUtils.rm_rf(dir, verbose: verbose?)
      mkdir(dir)
    end

    def copy_metadata(src, dst)
      stat = File.stat(src)
      File.chmod(stat.mode, dst)
      File.utime(stat.atime, stat.mtime, dst)
    end
  end
end