require 'serialport'

class Roomba
  attr_accessor :serial_port
  def initialize
    @serial_port = SerialPort.new('/dev/tty.FireFly-86A2-SPP', 115200, 8, 1, 0)
    # @serial_port.read_timeout = 100

    sleep 0.5
    write(128)
    sleep 0.2
    write(130)
  end

  def exit
    @serial_port.close
    puts 'exitting...'
    sleep 5
  end

  def write(args)
    if args.class == Array
      args.each do |arg|
        write(arg)
      end

      return true
    end

    p args
    @serial_port.write(args.chr)
  end

  def read
    data = []
    until (b = @serial_port.getbyte).nil?
      p data.push b
    end

    data
  end
end


roomba = Roomba.new

roomba.write [140, 0,9, 67,42, 67,42, 67,42, 63,30, 70,12, 67,40, 63,30, 70,12, 67,20]
roomba.write [141, 0]

sleep