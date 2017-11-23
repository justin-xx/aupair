require 'sinatra'
require 'singleton'

set :bind, '0.0.0.0'
set :views, Proc.new { File.join(root, "../views") }

CEC_COMMANDS = {
   "on"  => "10:04",
   "off" => "1F:36",
   "set source" => "1F:82:XX:00"
}

SOURCE = {
  "HDMI 1" => "10",
  "HDMI 2" => "20",
  "HDMI 3" => "30",
  "HDMI 4" => "40",
  "Smartcast" => "50"
}

class Television

  include Singleton

  def initialize(_address = 0)
    @address = 0
  end

  def turn_display_on
    cec_command('on')
  end

  def turn_display_off
    cec_command('off')
  end

  def set_source(src='HDMI 3')
    cec_command('set source', SOURCE[src])
  end

  private

  def cec_command(cmd = 'on', parameter = '')
    `echo "tx #{CEC_COMMANDS[cmd].gsub("XX", parameter)}" | cec-client -s -d 0`
  end

end


get '/' do
  @tv = Television.instance
  erb :television
end


get '/tv/off' do
  @tv = Television.instance
  @result = @tv.turn_display_off
  erb :television
end


get '/tv/on' do
  @tv = Television.instance
  @result = @tv.turn_display_on
  erb :television
end


get '/tv/hdmi1' do
  @tv = Television.instance
  @result = @tv.set_source('HDMI 1')
  erb :television
end


get '/tv/hdmi2' do
  @tv = Television.instance
  @result = @tv.set_source('HDMI 2')
  erb :television
end


get '/tv/hdmi3' do
  @tv = Television.instance
  @result = @tv.set_source('HDMI 3')
  erb :television
end


get '/tv/hdmi4' do
  @tv = Television.instance
  @result = @tv.set_source('HDMI 4')
  erb :television
end