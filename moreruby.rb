#!/usr/bin/ruby
# coding: utf-8
require 'optparse'
require 'fileutils'
require 'getoptlong'

def argument
  opts = GetoptLong.new(
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ]
  )
  opts.each do |opt|
    case opt
    when '--help'
      puts <<-EOF
Usage: ruby moreruby.rb [OPTION]
This program unpacks all tarballs, changes their names, uses the split-supportconfig function, deletes all .txt files, copies all the files from the rootfs directory to the current directory and deletes the old rootfs.

-h, --help:
   show help

      EOF
    #else
    #  run_task
    end      
  end
  
end
def arg_or_not
if ARGV.empty?
  Dir.glob("*.tbz"){|x| `tar -xf #{x}`}
  Dir.glob("*crowbar*[^a-z]"){|x|File.rename(x,"c")}
  count = 1
  Dir["*[0-9]"].each do |x|
    File.rename(x, count.to_s)
    count += 1
  end
  Dir.chdir("./c") do
    `split-supportconfig *.txt`
    Dir.glob("*.txt"){|x| File.delete(x)}
    FileUtils.cp_r Dir.glob("rootfs/*"), "."
    FileUtils.rm_r "./rootfs"
  end
  Dir["[0-9]"].each do |num|
    Dir.chdir(num) do
      `split-supportconfig *.txt`
      Dir.glob("*.txt"){|x| File.delete(x)}
      FileUtils.cp_r Dir.glob("rootfs/*"), "."
      FileUtils.rm_r "./rootfs"
    end
  end
else
  argument
end
end

arg_or_not

