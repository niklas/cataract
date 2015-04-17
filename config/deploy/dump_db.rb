namespace :db do
  desc "Sync database and assets from staging into (empty) local database (test is default, set RAILS_ENV to change)"
  task :sync_to_local do
    tmp = "/tmp/production.psql"
    target = ENV['RAILS_ENV'] || 'development'
    host = capture("echo $CAPISTRANO:HOST$").strip

    on_rollback do
      run "rm #{tmp}"
      system "rm #{tmp}"
    end

    # always dump the corresponding db
    run("#{deploy_to}/current/bin/dump production > #{tmp}") do |channel, stream, data|
      puts data
    end

    # but sync it as plaintext file to us so we don't have to download serveral 100MB every time.
    system "rsync -avzP #{user}@#{host}:#{tmp} #{tmp}"

    system "bin/restore #{target} < #{tmp}"

    # if you want assets, use backup:restore
    #system "rsync -avzP --delete --exclude 'custom' #{user}@#{host}:#{deploy_to}/current/public/sites/ public/sites/"
    #system "rsync -avzP --delete --exclude 'custom' #{user}@#{host}:#{deploy_to}/current/public/reels/ public/reels/"

    # cleanup
    run "rm #{tmp}"
  end

end

