#!/usr/bin/env ruby

RAILS_ENV = ENV['RAILS_ENV'] || 'production'
require File.dirname(__FILE__) + '/../config/environment'


class BTOutputEater
  def initialize(source='flupp')
    @source = source
    @logfile = 'bt.log'
  end

  def startup 
    @stop = false
    eater(3)
    teardown
  end

  def update_interface
    info "updating the interface"
    sleep 3
  end

  def teardown
    info "quitting..."
    exit
  end

  def eater(some_time=1)
    while not @stop # keeps reading until something other happens
      info "opening #{@source} for input"
      File.open(@source) do |input|
        while line = input.gets
          process_line(line)
        end
      end
      sleep some_time
    end
  end

  def process_line(line)
    line.chomp!
    return if line =~ /^\s*$/

    match_logentry(line) or
    match_torrent_entry(line) or
    info "EEE: don't know how to process or something went wrong: #{line}\n"
  end

  def match_torrent_entry(line)
    # perl would be nicer, indeed (x flag)
    ri = '(\d+)'
    rf = '(\d+\.\d+)'
    re_torrentstatus = %r(^"\./([^"]+\.torrent)":\s*"([^"]*)"\s*\(#{rf}%\)\s*-\s*#{ri}P#{ri}S#{rf}D\s*u#{rf}K/s-d#{rf}K/s\s*u#{ri}K-d#{ri}K\s*"([^"]*)"$)i
    if la = re_torrentstatus.match(line)
      t = {
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
      update(t)
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

  def update(attribs)
    filename = attribs[:filename]
    torrent = Torrent.find_by_filename(filename)
    unless torrent
      info "WWW: unknown torrent updated, registering: #{filename}'"
      torrent = Torrent.create(:filename => filename)
    end
    torrent.update_attributes(attribs)
  end

  def dropped(filename)
    torrent = Torrent.find_by_filename(filename)
    if torrent
      if @stop
        info "breaking #{filename}"
        torrent.brake 
      else
        info "pausing #{filename}"
        torrent.pause if torrent.status == 'running'
      end
      torrent.save
    else
      info "WWW: unknown torrent dropped: '#{filename}'"
    end
  end

  def added(filename)
    torrent = Torrent.find_by_filename(filename)
    unless torrent
      info "creating #{filename}"
      torrent = Torrent.create(:filename => filename)
    end
  end

  def info(*args)
    File.open(@logfile,'a+') do |f| 
      args.each do |line|
        f.puts "#{self.class}: #{line}"
      end
    end
  end
end

BTOutputEater.new.startup

