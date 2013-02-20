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

    say "赤外線モジュール接続"
    @iremocon = Iremocon.new '192.168.11.28'

    say "クロン登録"
    @cron_thread = Thread.new do
      while true
        time_str = Time.now.strftime('%H:%M')

        case(time_str)
        when '08:00'
          run_command '[点灯]', true
          run_command '[エアコン付けて]', true
        when '23:59'
          run_command '[消灯]', true
        else
          run_command '[iremocon_status]'
        end

        sleep 60
      end
    end

    say "音声認識モジュール接続"
    @julius_thread = Thread.new do
      systemu "julius -C room.jconf -module"
    end
    sleep 2
    @socket = TCPSocket.open('localhost', 10500)

    @light_status = :on
    @voice_input  = :on
  end

  def run_command(command, retry_when_error = false)
    return if (@voice_input == :off) &&
      !['[音声認識再開]', '[iremocon_status]'].include?(command) &&
      !retry_when_error

    puts "#{Time.now} #{command}"
    begin
      case(command)
      when '[電気付けて]'
        if @light_status == :off
          say '了解'
          @iremocon.is 1
          @light_status = :on
        end
      when '[電気消して]'
        if @light_status == :on
          say '了解'
          3.times do
            @iremocon.is 1
            sleep 1
          end
          @light_status = :off
        end
      when '[エアコン付けて]'
        say '了解'
        @iremocon.is 2
      when '[エアコン消して]'
        say '了解'
        @iremocon.is 3
      when '[ヒーター付けて]'
        say '了解'
        @iremocon.is 4
      when '[ヒーター消して]'
        say '了解'
        @iremocon.is 5
      when '[今何時？]'
        say "#{Time.now.strftime('%H:%M')}です。"
      when '[iremocon_status]'
        @iremocon.au
      when '[音声認識停止]'
        say '了解'
        @voice_input = :off
      when '[音声認識再開]'
        say '了解'
        @voice_input = :on
      end
    rescue Errno::EPIPE
      puts say "赤外線モジュール再接続"
      @iremocon = Iremocon.new '192.168.11.28'

      run_command(command) if retry_when_error
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
