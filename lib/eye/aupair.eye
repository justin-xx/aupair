# Eye self-configuration section
Eye.config do
  logger '/tmp/eye.log'
end

Eye.application 'aupair' do

  working_dir File.expand_path(File.join(File.dirname(__FILE__), %w[ processes ]))
  puts working_dir
  stdall 'trash.log' # stdout,err logs for processes by default
  env 'BUNDLE_GEMFILE' => File.join(working_dir, '/../../../Gemfile')
  trigger :flapping, times: 10, within: 1.minute, retry_in: 10.minutes
  check :cpu, every: 10.seconds, below: 100, times: 3 # global check for all processes
  
  # thin process, self daemonized
  process :thin do
    pid_file 'thin.pid'
    start_timeout 100.seconds
    start_grace 10.seconds
    start_command "/usr/local/bin/bundle exec thin start -R #{working_dir}/thin.ru -p 8080 -d -l #{working_dir}/thin.log -P #{working_dir}/thin.pid"
    stop_signals [:QUIT, 2.seconds, :TERM, 1.seconds, :KILL]
  end

  process :infoboard_current_conditions do
     pid_file 'infoboard-current-conditions.pid'
     daemonize true
     start_command '/usr/bin/python3 /home/pi/Documents/aupair/current/lib/infoboard/infoboard-current-conditions.py'
     stop_signals [:QUIT, 2.seconds, :TERM, 1.seconds, :KILL]
  end
  
  process :infoboard_five_day do
     pid_file 'infoboard-five-day.pid'
     daemonize true     
     start_command '/usr/bin/python3 /home/pi/Documents/aupair/current/lib/infoboard/infoboard-five-day.py'
     stop_signals [:QUIT, 2.seconds, :TERM, 1.seconds, :KILL]
  end
  
  process :infoboard_hourly do
     pid_file 'infoboard-hourly.pid'
     daemonize true     
     start_command '/usr/bin/python3 /home/pi/Documents/aupair/current/lib/infoboard/infoboard-hourly.py'
     stop_signals [:QUIT, 2.seconds, :TERM, 1.seconds, :KILL]
  end
  
  process :show_infoboard do
     pid_file 'show-infoboard.pid'
     daemonize true     
     start_grace 10.seconds
     start_command '/usr/bin/python3 /home/pi/Documents/aupair/current/lib/infoboard/show-infoboard.py'
     stop_signals [:QUIT, 2.seconds, :TERM, 1.seconds, :KILL]
  end
end