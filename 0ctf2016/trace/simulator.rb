#!/usr/bin/env ruby

require "awesome_print"


def int(str)
	return [str[2..-1].rjust(8,'0')].pack("H*").unpack("l>")[0]
end
def uint(str)
	#return [str[2..-1].rjust(8,'0')].pack("H*").unpack("l>")[0]
	return str.to_i(16)
end
@reg = Hash.new(0)
@mem = Hash.new(0)
skip = 0
chr = ""
save_str = ""
@mem[0x00410EA0] =  0x400D80
  @mem[0x400d80] = 0xcecdcccb
  @mem[0x400d84] = 0xd2d1d0cf
  @mem[0x400d88] = 0xd6d5d4d3
  @mem[0x400d8c] = 0xdad9d8d7
  @mem[0x400d90] = 0xdedddcdb
  @mem[0x400d94] = 0xe2e1e0df
  @mem[0x400d98] = 0x00e5e4e3
#    @mem[0x400d80] = 0x66746330
#    @mem[0x400d84] = 0x3172747b
#    @mem[0x400d88] = 0xd66d3533
#    @mem[0x400d8c] = 0xda6c356b
#    @mem[0x400d90] = 0xdedddcdb
#    @mem[0x400d94] = 0x356c39df
#    @mem[0x400d98] = 0x00007d72
  @reg['r29'] = 0xffff0000
#@mem[0x400d80]  = 0x4007a8
count = 0
check_jmp = 0
compare = []
File.open("mips.asm").each_line do |line|
    count = count + 1
#    break if count == 40
	if skip == 1
		skip = 0
		next
	end

	data = line.tr(',','').split " "
	inst = data[1]
	p data

    if check_jmp == 1
        check_jmp = 0
        pc = data[0][6..-1].to_i(16) 
        if compare[-1]['to'] == pc
            compare[-1]['is_jump'] = 1
        else
            compare[-1]['is_jump'] = 0 
        end

    end

	if inst == 'addiu'
		# [INFO]004009d4       addiu r29, r29, 0xfffffec8
		@reg[data[2]] = (@reg[data[3]] + int(data[4]) ) & 0xffffffff
	elsif inst == 'addu'
		# [INFO]0040078c                  addu r2, r3, r2
		@reg[data[2]] = (@reg[data[3]] + @reg[data[4]] ) & 0xffffffff
	elsif inst == 'subu'
		# [INFO]004009ac                  subu r2, r3, r2
		@reg[data[2]] = (@reg[data[3]] - @reg[data[4]] ) & 0xffffffff
	elsif inst == 'sw'	
		# [INFO]004009d8              sw r31, [r29+0x134]
		dst = data[3].tr('[]','').split('+')
		off = uint(dst[1])
		dr = dst[0]
		puts "Write #{@reg[data[2]] } to  #{@reg[dr] + off} ( 0x#{(@reg[dr] + off).to_s(16)} )"
		@mem[(@reg[dr] + off) & 0xffffffff] = @reg[data[2]]
	elsif inst == 'sb'	
		# [INFO]00400a48                sw r2, [r30+0x18]
		dst = data[3].tr('[]','').split('+')
		off = uint(dst[1])

		dr = dst[0]
		pad = ((@reg[dr]+off) % 0x4)
		mask = (0xff << (pad*8)) ^ 0xffffffff
		final = (@mem[(@reg[dr] + off) & 0xfffffffc] & mask )+ ((@reg[data[2]] & 0xff) << (pad*8))
		@mem[(@reg[dr] + off) & 0xfffffffc] = final 
		save_str = save_str + (@reg[data[2]] & 0xff).chr
		puts "Write Byte 0x#{final.to_s(16) } to  #{(@reg[dr] + off)&0xfffffffc} ( 0x#{((@reg[dr] + off)&0xfffffffc).to_s(16)} )"
	elsif inst == 'sll'
		# [INFO]00400a28                 sll r3, r2, 0x18	
		@reg[data[2]] =( @reg[data[3]] << uint(data[4])) & 0xffffffff 
	elsif inst == 'srl'
		# [INFO]00400a2c                 sra r3, r3, 0x18
		@reg[data[2]] =( @reg[data[3]] >> uint(data[4])) & 0xffffffff 
	elsif inst == 'sra'
		# [INFO]00400a2c                 sra r3, r3, 0x18
		if (@reg[data[3]] > 0x80000000) 
			@reg[data[3]] = @reg[data[3]] + 0xffffffff80000000
		end
		@reg[data[2]] =( @reg[data[3]] >> uint(data[4])) & 0xffffffff 
	elsif inst == 'move'
		# [INFO]004009e0                    move r30, r29
		@reg[data[2]] = @reg[data[3]]

	elsif inst == 'lui'
		# [INFO]004009e4                    lui r28, 0x42
		@reg[data[2]] = uint(data[3]) << 16
	elsif inst == 'lw'
		# [INFO]004009f4                lw r2, [r2+0xea0]
		dst = data[3].tr('[]','').split('+')
		off = uint(dst[1])
		dr = dst[0]
		puts "Read #{@mem[(@reg[dr] + off)] } from  #{(@reg[dr] + off)} ( 0x#{(@reg[dr] + off).to_s(16)} )"
		@reg[data[2]] = @mem[(@reg[dr] + off) & 0xffffffff] & 0xffffffff 
	elsif inst == 'lb' or inst=='lbu'
		# [INFO]00400790                  lb r2, [r2+0x0]
		dst = data[3].tr('[]','').split('+')
		off = uint(dst[1])
		dr = dst[0]
		pad = (@reg[dr]+off) % 0x4
		mask = (0xff << (pad*8)) 
		final = ((@mem[(@reg[dr] + off) & 0xfffffffc] & mask) >> (pad*8))
		puts "#{dr} = #{@reg[dr]}"
		puts "Read Byte 0x#{final.to_s(16) } #{final.chr} from  #{(@reg[dr] + off)} ( 0x#{(@reg[dr] + off).to_s(16)} )"
		chr = chr + final.chr
		@reg[data[2]] = final
	elsif inst == 'andi'
		# [INFO]00400a1c                andi r2, r2, 0xff
                @reg[data[2]] = @reg[data[3]] & uint(data[4])
                
	elsif inst=='slt'
        list = Hash.new()
        list['A'] = @reg[data[3]]
        list['B'] = @reg[data[4]]
        compare.push list.dup        
    elsif inst == 'beqz'
        # [INFO]004008c4                beqz r2, 0x400920
        compare[-1]['to'] = data[3].to_i(16)
        skip = 1
        check_jmp = 1
        next
	elsif inst == 'slti' 
		# [INFO]00400a50                slti r2, r2, 0x1a
        list = Hash.new()
        list['A'] = @reg[data[3]]
        list['B'] = data[4].to_i(16)
        compare.push list.dup        
		next
	elsif inst[0] == 'j' or inst[0] == 'b'
		skip = 1
		puts "#{data[2]} = #{@reg[data[2]]} , #{data[3]} = #{@reg[data[3]]}"
	 	next
		
	else
		puts "unknown command!!"
		break
	end
	puts "#{data[2]} =  #{@reg[data[2]]} ( 0x#{@reg[data[2]].to_s(16)} ) "
end

		ap @mem
		ap @reg

p chr.force_encoding("binary")
puts
puts
p save_str.force_encoding("binary")
p compare
compare.each do |h|
    if not h['to'].nil?
        if ( h['A'] >= 0xc0 and h['A'] <= 0xf5 ) 
            if h['is_jump'] == 1
                puts " #{h['A'].to_s(16)}  >= #{h['B'].to_s(16)} "
            else 
                puts " #{h['A'].to_s(16)}  < #{h['B'].to_s(16)} "
            end
        end
        if ( h['B'] >= 0xc0 and h['B'] <= 0xf5 ) 
            if h['is_jump'] == 0 
                puts " #{h['B'].to_s(16)}  > #{h['A'].to_s(16)} "
            else 
                puts " #{h['B'].to_s(16)}  <= #{h['A'].to_s(16)} "
            end
        end
    end
end
