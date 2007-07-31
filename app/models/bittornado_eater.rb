class BittornadoEater < OutputEater
  def match_torrent_entry(line)
    ri = '(\d+)'         # an integer
    rf = '(\d+\.\d+)'    # a float
    re_torrentstatus = /^
        "\.\/
          ([^"]+\.torrent)    # filename
        ":\s*"
          ([^"]*)             # statusmsg
        "\s*
          \(#{rf}%\)          # percent_done
        \s*-\s*
          #{ri}P              # peers
          #{ri}S              # seeds
          #{rf}D              # distributed_copies
        \s*u
          #{rf}               # rate_up
        K\/s\s*-d
          #{rf}               # rate_down
        K\/s\s*u
          #{ri}               # transferred_up
        K-d
          #{ri}               # transferred_down
        K\s*"
          ([^"]*)             # errormsg
        "$/xi
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
    if re_logentry.match(line)
      entry = $1.chomp
      case entry
      when /^dropped\s+"\.\/(.+)"$/
        dropped($1)
      when /^added\s+"\.\/(.+)"$/
        added($1)
      when 'shutting down'
        # we follow the king to death!
        info "waiting for bittorrent to quit (this can take a while)..."
        @stop = true
      else
        info "unknown message from btlaunchmany: #{entry}"
      end
      return true
    else
      return false
    end
  end
end
