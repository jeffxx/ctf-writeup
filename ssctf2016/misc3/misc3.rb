#!/usr/bin/env ruby
#
require 'faye/websocket'
require 'eventmachine'
require 'json'
username = "jeffxx.cs96@g2.nctu.edu.tw" 
password = "yuSKzDcjWJMP"
puts "Our post: " + '[{"act":"login","data":{"username":"' + username + '","password":"' + password+ '"}}]'

@player =""
@x = 0
@y = 0



@attacking = 0
EM.run {
  @ws = Faye::WebSocket::Client.new('ws://socket.lab.seclover.com:9000/')

  @ws.on :open do |event|
    p [:open]


    @ws.send('[{"act":"login","data":{"username":"' + username + '","password":"' + password+ '"}}]')
    @ws.send('[{"act":"next","data":{}}]')
    @ws.send('[{"act":"next","data":{}}]')
    5.times do
        @ws.send('[{"act":"wood","data":{"time":' + "2000000" +'}}]')
    end
    @ws.send('[{"act":"next","data":{}}]')
    500.times do
        @ws.send('[{"act":"diamond","data":{"count":' + "20" +'}}]')
    end
    @ws.send('[{"act":"next","data":{}}]')
#    ws.send('[{"act":"login","data":{"username":"admin","password": true}}]')
#    ws.send('[{"act":"login","data":{"username":"' + username + '","password":"' + password+ '"}}]')
    #ws.send('[{"act":"pos","data":{"x":0,"y":0}}]')
    #ws.send('[{"act":"pos","data":{"x":0,"y":0}}]')
    #ws.send('[{"act":"pos","data":{"x":0,"y":0}}]')
    #ws.send('[{"act":"pos","data":{"x":0,"y":0}}]')
    #ws.send('[{"act":"pos","data":{"x":0,"y":0}}]')
    #ws.send('[{"act":"attack","data":{"x":512,"y":512}}]')
    #ws.send('[{"act":"attack","data":{"x":512,"y":512}}]')
  end

  @ws.on :message do |event|
    p [:message, event.data]
    if event.data =~ /At last, the final/
        @player = JSON.parse(event.data)[2] 
        Thread.new {
            while true
                if @x != 0 and @y != 0
                    @ws.send('[{"act":"attack","data":{"x":'+ @x.to_s + ', "y": '+ @y.to_s + '}}]')
                    puts " Attack boss- x: #{@x} , y: #{@y}"
                
                end
                sleep 0.8 
            end
        }
        
    end
    
    if event.data =~ /\"act\": \"BOSS\"/
#       puts "attack!" 
          res = JSON.parse(event.data)
#  
          @x = res[0]["data"]["x"]
          @y = res[0]["data"]["y"]
#          puts '[{"act":"attack","data":{"x":'+ @x.to_s + ', "y": '+ @y.to_s + '}}]'
#      if @player !=""
#          @player.each do |a|
#  #                p a 
#              if a['act'] == 'gamer' and a['data']['status'] == 1 
#                  p a
#                  x = a["data"]["x"]
#                  y = a["data"]["y"]
#  #                @ws.send('[{"act":"pos","data":{"x":'+ x.to_s + ', "y": '+ (y-1).to_s + '}}]')
#  #\               @ws.send('[{"act":"attack","data":{"x":'+ x.to_s + ', "y": '+ y.to_s + '}}]')
#  #                puts "we attack #{a}" 
#                  break
#              end
#          end
#      end
        if @attacking == 0 
            @attacking = 1
#            @ws.send('[{"act":"attack","data":{"x":'+ @x.to_s + ', "y": '+ @y.to_s + '}}]')
#            puts " Attack boss- x: #{@x} , y: #{@y}"
            @attacking = 0
        end
    end
  end

  @ws.on :close do |event|
    p [:close, event.code, event.reason]
    @ws = nil
    exit
  end
}


