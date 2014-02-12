require "etc"
require "fileutils"

module Scripto
  module FileCommands
    # Like mkdir -p +dir+. If +owner+ is specified, the directory will be
    # chowned to owner. If +mode+ is specified, the directory will be chmodded
    # to mode. Like all file commands, the operation will be printed out if
    # verbose?.
    def mkdir(dir, owner: nil, mode: nil)
      FileUtils.mkdir_p(dir, verbose: verbose?)
      chown(dir, owner) if owner
      chmod(dir, mode) if mode
    end

    # Like cp -pr +src+ +dst. If +mkdir+ is true, the dst directoy will be
    # created if necessary before the copy. If +owner+ is specified, the
    # directory will be chowned to owner. If +mode+ is specified, the
    # directory will be chmodded to mode. Like all file commands, the
    # operation will be printed out if verbose?.
    def cp(src, dst, mkdir: false, owner: nil, mode: nil)
      mkdir_if_necessary(File.dirname(dst)) if mkdir
      FileUtils.cp_r(src, dst, preserve: true, verbose: verbose?)
      chown(dst, owner) if owner && !File.symlink?(dst)
      chmod(dst, mode) if mode
    end

    # Like mv +src+ +dst. If +mkdir+ is true, the dst directoy will be created
    # if necessary before the copy. Like all file commands, the operation will
    # be printed out if verbose?.
    def mv(src, dst, mkdir: false)
      mkdir_if_necessary(File.dirname(dst)) if mkdir
      FileUtils.mv(src, dst, verbose: verbose?)
    end

    # Like ln -sf +src+ +dst. The command will be printed out if
    # verbose?.
    def ln(src, dst)
      begin
        FileUtils.ln_sf(src, dst, verbose: verbose?)
      rescue Errno::EEXIST => e
        # It's a race - this can occur because ln_sf removes the old
        # dst, then creates the symlink. Raise if they don't match.
        raise e if !(File.symlink?(dst) && src == File.readlink(dst))
      end
    end

    # Like rm -f +file+. Like all file commands, the operation will be printed
    # out if verbose?.
    def rm(file)
      FileUtils.rm_f(file, verbose: verbose?)
    end

    # Runs #mkdir, but ONLY if +dir+ doesn't already exist. Returns true if
    # directory had to be created. This is useful with verbose?, to get an
    # exact changelog.
    def mkdir_if_necessary(dir, owner: nil, mode: nil)
      if !(File.exists?(dir) || File.symlink?(dir))
        mkdir(dir, owner: owner, mode: mode)
        true
      end
    end

    # Runs #cp, but ONLY if +dst+ doesn't exist or differs from +src+. Returns
    # true if the file had to be copied. This is useful with verbose?, to get
    # an exact changelog.
    def cp_if_necessary(src, dst, mkdir: false, owner: nil, mode: nil)
      if !(File.exists?(dst) && FileUtils.compare_file(src, dst))
        cp(src, dst, mkdir: mkdir, owner: owner, mode: mode)
        true
      end
    end

    # Runs #ln, but ONLY if +dst+ isn't a symlink or differs from +src+.
    # Returns true if the file had to be symlinked. This is useful with
    # verbose?, to get an exact changelog.
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

    # Runs #rm, but ONLY if +file+ exists. Return true if the file had to be
    # removed. This is useful with verbose?, to get an exact changelog.
    def rm_if_necessary(file)
      if File.exists?(file)
        rm(file)
        true
      end
    end

    # Like chown user:user file. Like all file commands, the operation will be printed
    # out if verbose?.
    def chown(file, user)
      # who is the current owner?
      @scripto_uids ||= {}
      @scripto_uids[user] ||= Etc.getpwnam(user).uid
      uid = @scripto_uids[user]
      if File.stat(file).uid != uid
        FileUtils.chown(uid, uid, file, verbose: verbose?)
      end
    end

    # Like chmod mode file. Like all file commands, the operation will be
    # printed out if verbose?.
    def chmod(file, mode)
      if File.stat(file).mode != mode
        FileUtils.chmod(mode, file, verbose: verbose?)
      end
    end

    # Like rm -rf && mkdir -p. Like all file commands, the operation will be
    # printed out if verbose?.
    def rm_and_mkdir(dir)
      raise "don't do this" if dir == ""
      FileUtils.rm_rf(dir, verbose: verbose?)
      mkdir(dir)
    end

    # Copy mode, atime and mtime from +src+ to +dst+. This one is rarely used
    # and doesn't echo.
    def copy_metadata(src, dst)
      stat = File.stat(src)
      File.chmod(stat.mode, dst)
      File.utime(stat.atime, stat.mtime, dst)
    end
  end
end