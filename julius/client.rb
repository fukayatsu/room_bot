#!/usr/bin/env ruby
# coding: utf-8

require 'socket'
require 'nokogiri'
require 'pp'
require 'iremocon'

iremocon = Iremocon.new '192.168.11.28'
socket = TCPSocket.open('localhost', 10500)

data = ""
while true
  data += socket.recv(65535)
  if data[-2..-1] == ".\n"
    data.gsub!(/\.\n/, '')
    xml = Nokogiri(data)

    commands = (xml/"RECOGOUT"/"SHYPO"/"WHYPO").map { |w|
      w["WORD"].size > 0 ? w["WORD"] : nil
    }.compact

    command = commands[0]

    case(command)
    when '[今何時？]'
      # macos lionでKyokoをインストールしておくこと
      `say -v Kyoko #{Time.now.strftime('%H:%M')}です。`
    when '[電気付けて]'
      iremocon.is 1
    when '[消灯]'
      3.times do
        iremocon.is 1
        sleep 0.5
      end
    when '[エアコン付けて]'
      iremocon.is 2
    when '[エアコン止めて]'
      iremocon.is 3
    end

    data = ""
  end
end