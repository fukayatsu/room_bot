# coding: utf-8

require 'dino'
require 'twitter'
require 'yaml'
require 'pp'

board = Dino::Board.new(Dino::TxRx.new)
light_sensor = Dino::Components::Sensor.new(pin: 'A0', board: board)
temperature_sensor = Dino::Components::Sensor.new(pin: 'A2', board: board)

light_dataset = []
light_sensor.when_data_received(Proc.new { |data|
  light_dataset << data.to_i
})

temp_dataset = []
temperature_sensor.when_data_received(Proc.new { |data|
  temp_dataset << data.to_i
})

sleep 2

light_value = light_dataset.inject(:+).to_f / light_dataset.size
temp_value  = temp_dataset.inject(:+).to_f / temp_dataset.size

light_str = "%1.1f" % Math.log(light_value + 1.0)
temp_str  = "%2.1f" % (temp_value / 1024 * 5 / 0.01)

puts status_str = "temperature:#{temp_str}, light:#{light_str}, time:#{Time.now}"

### twitter status update

ROOT_DIR    = File.expand_path(File.dirname(__FILE__))
CONFIG_PATH = File.join(ROOT_DIR, 'config.yml')
CONFIG      = YAML.load_file(CONFIG_PATH)

Twitter.configure do |config|
  c = CONFIG['twitter']
  config.consumer_key       = c['consumer_key']
  config.consumer_secret    = c['consumer_secret']
  config.oauth_token        = c['oauth_token']
  config.oauth_token_secret = c['oauth_token_secret']
end

Twitter.update(status_str)