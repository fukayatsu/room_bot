# coding: utf-8
require 'dino'

VCC = 5.0
VOLTS_PER_TEMP = 0.01
DATA_MAX = 1024

board = Dino::Board.new(Dino::TxRx.new)
sensor = Dino::Components::Sensor.new(pin: 'A2', board: board)

dataset = []
on_data = Proc.new do |data|
  dataset << data.to_i

  if (dataset.size >= 64)
    temperature = dataset.inject(:+).to_f / dataset.size / DATA_MAX / VOLTS_PER_TEMP * VCC
    puts "%2.1f度" % temperature
    dataset = []
  end
end

sensor.when_data_received(on_data)

sleep