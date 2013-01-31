require 'serialport'

class Roomba
  def initialize
    @serial_port = SerialPort.new('/dev/tty.FireFly-86A2-SPP', 115200, 8, 1, 0)

    write([128, 130])
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

    @serial_port.write(args.chr)
    sleep 0.2
  end
end


roomba = Roomba.new
roomba.write(135)
roomba.exit