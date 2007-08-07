class BittornadoEater < OutputEater
  def match_torrent_entry(line)
    ri = '(\d+)'         # an integer
    rf = '(\d+\.\d+)'    # a float
    re_torrentstatus = /^
        ".*\/                 # preceeding foo
          ([^"]+\.torrent)    # just the filename
        ":\s*"
          ([^"]*)             # statusmsg
        "\s*
          \(#{rf}%\)          # percent_done
        \s*-\s*
          #{ri}P              # peers
          #{ri}S              # seeds
          #{rf}D              # distributed_copies
        \s*
          u#{rf}               # rate_up
        K\/s\s*-
          d#{rf}               # rate_down
        K\/s\s*
          u#{ri}               # transferred_up
        K-
          d#{ri}               # transferred_down
        K\s*
          (?:
           "
            ([^"]*)             # optional errormsg
           " 
          )?
        $/xi
    if la = re_torrentstatus.match(line)
      return {
        :filename     => la[1],
        :statusmsg    => la[2],
        :percent_done => la[3].to_f,
        :peers        => la[4].to_i,
        :seeds        => la[5].to_i,
        :distributed_copies => la[6].to_f,
        :rate_up      => la[7].to_f,
        :rate_down    => la[8].to_f,
        :transferred_up  => la[9].to_i,
        :transferred_down=> la[10].to_i,
        :errormsg     => la[11]
      }
    else
      return false
    end
  end
  def match_logentry(line)
    re_logentry = /^###\s*(.*)$/
    re_path = '.*\/'
    if re_logentry.match(line)
      entry = $1.chomp
      case entry
      when /^dropped\s+"#{re_path}(.+)"$/
        dropped($1)
      when /^added\s+"#{re_path}(.+)"$/
        added($1)
      when /^\*\*warning\*\* .*dummy.torrent has errors$/
        info "found dummy torrent"
      when 'shutting down'
        # we follow the king to death!
        info "bittornado is quitting, saving caches (this can take a while)..."
        @stop = true
      else
        info "unknown message from btlaunchmany: #{entry}"
      end
      return true
    else
      return false
    end
  end
  def prepare
    system("touch '#{File.expand_path('dummy.torrent', Settings.torrent_dir)}'")
    here = File.dirname(__FILE__)
    client = File.expand_path('../../bin/BitTornado-CVS/btlaunchmany.py', here )
    @source = <<BITTORNADO
        python -u #{client} '#{Settings.torrent_dir}'
                --display_interval #{Settings.interval} 
                --spew 1 
                --random_port 0
                --minport #{Settings.min_port}
                --maxport #{Settings.max_port}
                --buffer_reads 0
                --auto_flush 60
                --saveas_style 2
                --max_upload_rate #{Settings.max_up_rate}
                --max_uploads 2
BITTORNADO
    @source.gsub!(/\n/,' ')
    @source.squeeze!(' ')
    @source.strip!
  end

  def stop(io)
    info "stopping bittornado, waiting for feedback.."
    io.puts "q" if io.is_a? IO
  end
end
