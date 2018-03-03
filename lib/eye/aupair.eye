# Eye self-configuration section
Eye.config do
  logger '/tmp/eye.log'
end

Eye.application 'aupair' do

  working_dir File.expand_path(File.join(File.dirname(__FILE__), %w[ processes ]))
  stdall 'trash.log' # stdout,err logs for processes by default
  env 'APP_ENV' => 'production' # global env for each processes
  trigger :flapping, times: 10, within: 1.minute, retry_in: 10.minutes
  check :cpu, every: 10.seconds, below: 100, times: 3 # global check for all processes
  
  # thin process, self daemonized
  process :thin do
    pid_file 'thin.pid'
    start_command 'bundle exec thin start -R thin.ru -p 8080 -d -l thin.log -P thin.pid'
    stop_signals [:QUIT, 2.seconds, :TERM, 1.seconds, :KILL]

    check :http, url: 'http://127.0.0.1:8080/lights', pattern: /World/,
                 every: 5.seconds, times: [2, 3], timeout: 1.second
  end
  
  
end
