require 'singleton'
require 'json'

class Television
  
  CEC_COMMANDS = {
     "on"  => "10:04",
     "off" => "1F:36",
     "set_source" => "1F:82:XX:00"
  }

  SOURCE = {
    "HDMI 1" => "10",
    "HDMI 2" => "20",
    "HDMI 3" => "30",
    "HDMI 4" => "40",
    "Smartcast" => "50"
  }

  include Singleton

  def initialize(_address = 0)
    @address = 0
    @status = 'off'
    @active_source = nil
  end

  def turn_display_on
    cec_command('on')
    @status = 'on'
  end

  def turn_display_off
    cec_command('off')
    @status = 'off'
  end

  def set_source(src='HDMI 1')
    cec_command('on')
    sleep 1
    cec_command('set_source', SOURCE[src])
    @active_source = src
  end
  
  def to_json
    {
      address: @address,
      status:  @status,
      source:  @active_source,
      result:  @result
    }.to_json
  end

  private

  def cec_command(cmd = 'on', parameter = '')
    @result = begin
      execute_command(cmd, parameter)      
    rescue Exception => e
      "\n\n\n\nAn error has occurred\n\n#{e}\n\n#{e.backtrace}\n\n\n\n"
    end
  end
  
  def execute_command(cmd = 'on', parameter = '')
    `echo "tx #{CEC_COMMANDS[cmd].gsub("XX", parameter)}" | cec-client -s -d 1`
  end

end
