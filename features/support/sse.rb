Before '@sse' do
  require 'foreman/engine/cli'
  $foreman = Foreman::Engine::CLI.new
  $foreman.load_procfile 'Procfile'
  sse = $foreman.process('sse')
  $sse_pid = sse.run
  $stderr.puts "started sse, pid: #{$sse_pid}, giving it 2s"
  sleep 2
end

After '@sse' do
  if $sse_pid
    Process.kill 'KILL', $sse_pid
  end
end
