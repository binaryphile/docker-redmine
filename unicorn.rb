APP_ROOT = "/redmine"

worker_processes ENV["U_WORKERS"] || 2
working_directory APP_ROOT

timeout 180

listen 3001

pid APP_ROOT + "/pids/unicorn.pid"

stderr_path APP_ROOT + "/log/unicorn.stderr.log"

preload_app true

GC.respond_to?(:copy_on_write_friendly=) and  GC.copy_on_write_friendly = true

before_exec do |server|
  ENV["BUNDLE_GEMFILE"] = APP_ROOT + "/Gemfile"
end

before_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.connection.disconnect!

  # kills old children after zero downtime deploy
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
    end
  end

  sleep 1
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) and ActiveRecord::Base.establish_connection

  defined?(Rails) and Rails.cache.respond_to?(:reconnect) and Rails.cache.reconnect
end
