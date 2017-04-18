#!/usr/bin/ruby
# coding: utf-8
require 'fileutils'
require 'getoptlong'
require 'net/sftp'
require 'rubygems'

def argument
  opts = GetoptLong.new(
    [ '--help', '-h', GetoptLong::NO_ARGUMENT ],
    ['-f', GetoptLong::OPTIONAL_ARGUMENT],
    ['-u', GetoptLong::OPTIONAL_ARGUMENT]
  )
  scp_hostname = nil
  scp_username = nil
  opts.each do |opt, arg|
    case opt
    when '--help'
      puts <<-EOF
Usage: ruby moreruby.rb [OPTION]
This program unpacks all tarballs, changes their names, uses the split-supportconfig function, deletes all .txt files, copies all the files from the rootfs directory to the current directory and deletes the old rootfs.

-h, --help:
   show help
-f HOSTADRESS:
   fetches files from host
-u USERNAME:
   requires a username

      EOF
    when '-f'
      scp_hostname = arg.to_s
    when '-u'
      scp_username = arg.to_s
      Net::SFTP.start( scp_hostname, scp_username ) do |sftp|
        sftp.dir.glob("/#{scp_username}/varlog", "nts_*.tbz") do |file|
          sftp.download!( "/#{scp_username}/varlog/#{file.name}", "./#{file.name}" )
        end
      end
      tarballs
    end      
  end
end


def new_name
  Dir.glob("*crowbar*[^a-z]"){|x|File.rename(x,"c")}
  count = 1
  Dir["*[0-9]"].each do |x|
    File.rename(x, count.to_s)
    count += 1
  end
end

def file_split
  `split-supportconfig *.txt`
    Dir.glob("*.txt"){|x| File.delete(x)}
    FileUtils.cp_r Dir.glob("rootfs/*"), "."
    FileUtils.rm_r "./rootfs"
end

def tarballs
   Dir.glob("*.tbz"){|x| `tar -xf #{x}`}
    new_name
    Dir.chdir("./c") do
      file_split
    end
    Dir["[0-9]"].each do |num|
      Dir.chdir(num) do
        file_split
      end
    end
end



def arg_choose
  if ARGV.include? '-h'
    argument
  elsif ARGV.include? '--help'
    argument
  elsif ARGV.include? '-f'
    argument
  else
    tarballs
  end
end

arg_choose



