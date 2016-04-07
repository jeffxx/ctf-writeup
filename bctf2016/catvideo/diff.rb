#!/usr/bin/env ruby

require 'chunky_png'
a = ChunkyPNG::Image.from_file("thumb1800.png")
b = ChunkyPNG::Image.from_file("thumb1801.png")
c = ChunkyPNG::Image.new(640,360, ChunkyPNG::Color::TRANSPARENT )
0.upto 639 do |x|
    0.upto 359 do |y|
        tmp = b[x,y]
        br = ChunkyPNG::Color.r( tmp )
        bg = ChunkyPNG::Color.g( b[x,y] )
        bb = ChunkyPNG::Color.b( b[x,y] )
        ar = ChunkyPNG::Color.r( a[x,y] )
        ag = ChunkyPNG::Color.g( a[x,y] )
        ab = ChunkyPNG::Color.b( a[x,y] )
        red = ( br ^ ar) %256
        green = ( bg ^ ag) %256
        blue = ( bb ^ ab) %256
#        red = 0
 #       green = 0
 #       blue = 0
#        next if red > 250 or green > 250 or blue > 250
          
        c[x,y] = ChunkyPNG::Color.rgb(red,green,blue)
        puts "#{x},#{y} : #{c[x,y].to_s(16)}"
    end
end
c.save("0test5.png", :interlace => true)
