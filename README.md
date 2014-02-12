# Scripto

Scripto is a framework for writing command line applications. It fills in many of the blanks that Ruby's standard library is missing:

* **print to $stderr** - Colored banners and a verbose mode to make your scripts louder.
* **file operations** - Mkdir, cp, mv, ln. These operations can take care of common edge cases, like creating the target directory before copying a file.
* **run commands** - Run external commands and raise errors on failure.
* **csv** - Read and write CSV files from hashes, Structs, or OpenStructs.

Rdoc at [rdoc.info](http://rdoc.info/github/gurgeous/scripto/). Thanks!

## Getting Started

You can call Scripto directly:

```ruby
require "scripto"

Scripto.banner("Starting installation...")
Scripto.cp("here.txt", "there.txt")
Scripto.mv("there.txt", "and_back.txt")

rows = [ ]
rows << { name: "Adam", score: 100 }
rows << { name: "Patrick", score: 99 }
Scripto.csv_write("scores.csv", rows)

if Scripto.fails("which git")
  Scripto.run("brew install git")
end

Scripto.run("touch script_complete.txt")
```

You can also subclass `Scripto::Main`:

```ruby
#!/usr/bin/env ruby

require "scripto"

class Install < Scripto::Main
  def initialize(options = {})
    verbose! if options[:verbose]

    banner("Starting installation...")
    cp("here.txt", "there.txt")
    mv("there.txt", "and_back.txt")

    rows = [ ]
    rows << { name: "Adam", score: 100 }
    rows << { name: "Patrick", score: 99 }
    csv_write("scores.csv", rows)

    if fails("which git")
      run("brew install git")
    end

    run("touch script_complete.txt")
  end
end

Install.new(verbose: true)
```

## Methods

### Print to $stderr

```
banner(str)  - print a banner in green
warning(str) - print a warning in yellow
fatal(str)   - print a fatal error in red, then exit(1)

verbose!     - turn on verbose mode
vbanner(str) - print a colored banner in green if verbose is on
vprintf(str) - printf if verbose is on
vputs(str)   - puts if verbose is on
```

### File operations

These operations are silent by default. If verbose is turned on, each command will be echoed first.

```
mkdir(dir)                 - mkdir -p dir
cp(src, dst, mkdir: false) - cp -p src dst, mkdir if necessary
mv(src, dst, mkdir: false) - mv src dst, mkdir if necessary
ln(src, dst, mkdir: false) - ln -sf src dst, mkdir if necessary
rm(file)                   - rm -f file
```

Each of these operations also has an "if_necessary" variant that only runs the operation if necessary. For example, `mkdir_if_necessary` only calls `mkdir` if the directory doesn't exist. When combined with verbose mode, this produces **a nice changelog** as the operations are run. You can run your script repeatedly and it'll only output actual changes.

Plus a few more:

```
chown(file, user)       - chown user:user file
chmod(file, mode)       - chmod mode file
rm_and_mkdir(dir)       - rm -rf dir && mkdir -p dir (for tmp dirs)
copy_metadata(src, dst) - copy mode/atime/mtime from src to dst
```

### Run external commands (system, backtick, etc)

Each of these methods takes a `command` and an optional array of `args`. Use it like so:

```
run("echo hello world")        # this will use a shell
run("echo, ["hello", "world"]) # NO shell, runs echo directly
```

This is like `Kernel#system` works - you can use the second variant (the array of arguments) to sidestep shell escaping issues. For example, these are the same but the second variant doesn't require those pesky single quotes:

```
run("cp file 'hello world")
run("cp, ["file", "hello world"])
```

Here are the various run commands:

```
run(command, args = nil)           - run a command, raise an error
run_capture(command, args = nil)   - capture the output similar to backtick, raise on error
run_quietly(command, args = nil)   - redirect stdout/stderr to /dev/null, raise on error

run_succeeds?(command, args = nil) - return true if command succeeds
run_fails?(command, args = nil)    - return true if command fails
```

### CSV read/write

Light wrappers around the CSV class built into Ruby. Used exclusively with hash-like objects, not arrays. The header row turns into the keys for the hash.

```
csv_read(path)        - read a CSV, returns an array of Structs. Path can be a .gz.
csv_write(path, rows) - write rows to a CSV. Rows can be hashes, Structs or OpenStructs.
csv_to_stdout(rows)   - write rows to stdout, like csv_write
csv_to_s(rows)        - write rows to a string, like csv_write
```

### Misc

There are a few more useful tidbits in here:

```
whoami             - just like the command
root?              - return true if we're running as root
md5_file(path)     - calculate md5 for a file
md5_string(str)    - calculate md5 for a string
prompt?(question)  - ask the user a question, return true if they say yes
random_string(len) - calculate a random alphanumeric string
```
