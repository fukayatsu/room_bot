#!/usr/bin/env ruby
# coding: utf-8

require 'socket'
require 'nokogiri'
require 'pp'

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
    end

    data = ""
  end
end