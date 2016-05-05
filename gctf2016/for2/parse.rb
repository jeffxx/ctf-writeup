#!/usr/bin/env ruby
#
#
require 'chunky_png'
c = ChunkyPNG::Image.new(2048,1720, ChunkyPNG::Color::TRANSPARENT )
initx = 1000
inity = 800
line = File.open("dump.txt").read
line.each_line do |data|
    (w,x,y,z) = data.split(":").map {|b| b.to_i(16)}

    if w >  128
        w = w - 256
    end
    if x >  128
        x = x - 256
    end
    if y >  128
        y = y - 256
    end
        if z >  128
        z = z - 256
    end
    initx = initx +x
    inity = inity +y
    if w != 0
        0.upto 5 do |i|
            0.upto 5 do |j|
                c[initx+i,inity+j] = ChunkyPNG::Color.rgb(255,255,0)
            end
        end
    end
    c[initx,inity] = ChunkyPNG::Color.rgb(255,0,0)

end
        c.save("record.png",:interlace => true)
