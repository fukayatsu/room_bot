#!/usr/bin/env ruby
# coding: utf-8

require 'socket'
require 'nokogiri'
require 'pp'
require 'iremocon'

iremocon = Iremocon.new '192.168.11.28'
socket = TCPSocket.open('localhost', 10500)

light_status = :on

data = ""
while true
  data += socket.recv(65535)
  next unless data[-2..-1] == ".\n"

  data.gsub!(/\.\n/, '')
  xml = Nokogiri(data)
  data = ""

  commands = (xml/"RECOGOUT"/"SHYPO"/"WHYPO").map { |w|
    w["WORD"].size > 0 ? w["WORD"] : nil
  }.compact

  puts command = commands[0]

  case(command)
  when '[電気付けて]'
    next if light_status == :on
    iremocon.is 1
    light_status = :on
  when '[電気消して]', '[消灯]'
    # TODO: 明るさセンサーを組み込む
    next if light_status == :off
    3.times do
      iremocon.is 1
      sleep 1
    end
    light_status = :off
  when '[エアコン付けて]'
    iremocon.is 2
  when '[エアコン止めて]', '[エアコン消して]'
    iremocon.is 3
  when '[今何時？]'
    # macos lionでKyokoをインストールしておくこと
    `say -v Kyoko #{Time.now.strftime('%H:%M')}です。`
  when '[おはよう]'
    # `say -v Kyoko おはようございます` #=> 無限ループ
    # TODO: 日次・曜日の読み上げ、天気情報
  when '[おやすみ]'
    # `say -v Kyoko おやすみなさい` #=> 無限ループ
    # TODO: エアコン、照明を消す
  when '[ただいま]'
    `say -v Kyoko おかえりなさい`
    # 照明ON、温度によってはエアコンを付ける
  when '[行ってきます]'
    # `say -v Kyoko いってらっしゃい` #=> 無限ループ
    # 照明OFF、エアコンOFF
  end

end