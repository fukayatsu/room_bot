#!/usr/bin/env ruby
# coding: utf-8

require 'socket'
require 'nokogiri'
require 'iremocon'
require 'systemu'
require 'pp'

class Roombot
  def initialize
    say "プログラム開始"

    say "赤外線モジュール接続開始"
    @iremocon = Iremocon.new '192.168.11.28'

    say "音声認識開始"
    @julius_thread = Thread.new do
      systemu "julius -C room.jconf -module"
    end
    sleep 2
    @socket = TCPSocket.open('localhost', 10500)

    @light_status = :on
  end

  def run_command(command)
    begin
      case(command)
      when '[電気付けて]', '[点灯]'
        if @light_status == :off
          @iremocon.is 1
          @light_status = :on
        end
      when '[電気消して]', '[消灯]'
        if @light_status == :on
          3.times do
            @iremocon.is 1
            sleep 1
          end
          @light_status = :off
        end
      when '[エアコン付けて]'
        @iremocon.is 2
      when '[エアコン止めて]', '[エアコン消して]'
        @iremocon.is 3
      when '[今何時？]'
        say "#{Time.now.strftime('%H:%M')}です。"
      end
    rescue Errno::EPIPE
      puts say "赤外線モジュール再接続"
      @iremocon = Iremocon.new '192.168.11.28'
    end
  end

  def wait_for_command
    data = ""
    while true
      data += @socket.recv(65535)
      next unless data_end?(data)

      command = parse_data(data)
      data = ""

      run_command(command) if command
    end
  end

  private

  def say(text)
    `say -v Kyoko #{text}`
    text
  end

  def data_end?(data)
    data[-2..-1] == ".\n"
  end

  def parse_data(data)
    data.gsub!(/\.\n/, '')
    xml = Nokogiri(data)

    commands = (xml/"RECOGOUT"/"SHYPO"/"WHYPO").map { |w|
      w["WORD"].size > 0 ? w["WORD"] : nil
    }.compact

    commands[0]
  end
end

roombot = Roombot.new
roombot.wait_for_command
