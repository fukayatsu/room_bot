# coding: utf-8
require 'dino'

board = Dino::Board.new(Dino::TxRx.new)
sensor = Dino::Components::Sensor.new(pin: 'A0', board: board)

dataset = []
on_data = Proc.new do |data|
  dataset << data.to_i

  if (dataset.size >= 64)
    average = dataset.inject(:+).to_f / dataset.size
    puts "%4.1f" % average
    dataset = []
  end
end

sensor.when_data_received(on_data)

sleep