#!/usr/bin/env ruby
#
#
require 'rubypwn'

map = Hash.new(-1)
cache = Hash.new(-1) 
f = File.open("1g.img","r+")
f.sync = true
nc = Exec.new 'tshark -T fields -e ip.src -e nbd.type  -e nbd.from -e nbd.data -e nbd.handle -r no-big-deal.pcap "nbd && frame.time_relative<=503.736152 "' # !(frame.time_relative >= 438.301754 && frame.time_relative<=497.805885) "' # && !(frame.time_relative>=504.091335)"'
#nc = Exec.new 'tshark -T fields -e ip.src -e nbd.type  -e nbd.from -e nbd.data -e nbd.handle -r no-big-deal.pcap "nbd && !(frame.time_relative >= 438.301754 && frame.time_relative<=497.805885) && !(frame.time_relative>=504.091335)"'
nc.debug = false 
count = 0
while line = nc.gets
a = line.split("\t")
#puts "src: #{a[0]} , type #{a[1]} , offset #{a[2]} , handle #{a[4]}"
#next
#next if a[2].nil? or a[2].empty?

    if a[1] == "0" and a[0] == "10.240.0.12"
        pos = a[2].to_i(16)
        handle = a[4].to_i(16)
        map[handle] = pos
        puts "Read request handle: #{handle.to_s(16)} , offset: #{pos.to_s(16)}"
        #end
    end
    if a[1] == "0" and a[0] == "10.240.0.3"
        handle = a[4].to_i(16)
        pos = map[handle]
	next if map[handle] == -1
        data = a[3].chop.tr ":",""
        f.seek(pos, IO::SEEK_SET)  
            data = [data].pack("H*")
            f.write(data)
	map[handle] = -1
        puts "Read response, write data to #{pos.to_s(16)} , size: #{data.size}"
        #end
    end
    # write data
    if a[1] == '1' and a[0] == "10.240.0.12"
        handle = a[4].to_i(16)
        pos = a[2].to_i(16)

        data = a[3].chop.tr ":",""
        #if not data.each_char.all? {|x| x=='0'}
            data = [data].pack("H*")
	    cache[handle] = data
	    map[handle] = pos
            #count = count + 1
        #break if count == 20 
        puts "Write request, handle: #{handle.to_s(16)} , offset: #{pos.to_s(16)}"


        #    break if pos == 0x201c5000
        #end
    end
    if a[1] == '1' and a[0] == "10.240.0.3"
            handle = a[4].to_i(16)
	    pos = map[handle]
	    next if map[handle] == -1
	    f.seek(pos, IO::SEEK_SET)  
            f.write(cache[handle])
	    map[handle] = -1
            puts "Write response, Write data to #{pos.to_s(16)} size: #{data.size}"
	
    end
end
f.close
