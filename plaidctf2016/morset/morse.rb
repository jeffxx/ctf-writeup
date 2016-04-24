#!/usr/bin/env ruby
#
require 'rubypwn'
class Exec
# Hashtable from http://www.saalonmuyo.com/2010/03/22/morse-code-translator-in-ruby/
  @@morse = {'a' => '.-',
              'b' => '-...',
              'c' => '-.-.',
              'd' =>'-..',
              'e' => '.',
              'f' => '..-.',
              'g' => '--.',
              'h' => '....',
              'i' => '..',
              'j' => '.---',
              'k' => '-.-',
              'l' => '.-..',
              'm' => '--',
              'n' => '-.',
              'o' => '---',
              'p' => '.--.',
              'q' => '--.-',
              'r' => '.-.',
              's' => '...',
              't' => '-',
              'u' => '..-',
              'v' => '...-',
              'w' => '.--',
              'x' => '-..-',
              'y' => '-.--',
              'z' => '--..',
              '1' => '.----',
              '2' => '..---',
              '3' => '...--',
              '4' => '....-',
              '5' => '.....',
              '6' => '-....',
              '7' => '--...',
              '8' => '---..',
              '9' => '----.',
              '0' => '-----'}
            

    def read_line 
      morse_inv = @@morse.invert
      input = read_until("\n")
      
      resp = input.split(" ").map {|i| morse_inv[i]}.join
      hex = resp.to_i(36).to_s(16)
      hex = "0" + hex if hex.size % 2 == 1
      resp = [hex].pack("H*")
      resp
    end
    def send_line line
#        STDERR.puts line
        morse = @@morse
        base36 = line.unpack("H*")[0].to_i(16).to_s(36)
        out = base36.each_byte.map{ |c| morse[c.chr] }.join " "
        p out

        puts out
    end
end


nc = Exec.new ("nc morset.pwning.xxx 11821")
resp = nc.read_line

puts resp

resp =~ /SHA256\((.*)\)/
challenge=$1
hash = Digest::SHA256.hexdigest challenge

nc.send_line hash

error = nc.read_line

p error


