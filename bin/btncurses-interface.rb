#!/usr/bin/env ruby

RAILS_ENV = ENV['RAILS_ENV'] || 'production'
require "ncurses"
require File.dirname(__FILE__) + '/../config/environment'
require 'action_view/helpers/number_helper.rb'
require File.dirname(__FILE__) + '/../app/helpers/torrents_helper'

class BTCurses 
  attr_reader :term_width, :term_height
  include ActionView::Helpers::NumberHelper
  include TorrentsHelper

  def initialize
    Ncurses.initscr
    Ncurses.noecho
    @c = Ncurses.newwin(0,0,0,0)
    @delay = 1.0
    @total_up = 0 
    @total_down = 0
    mesure
  end

  def clear
    Ncurses.wclear(@c)
    @minwidth = 23
    @too_small = false
  end

  def width
    @screenw.to_s.to_i
  end

  def height
    @screenh.to_s.to_i
  end

  def mesure
    @screenh = Array.new
    @screenw = Array.new 
    Ncurses.getmaxyx(@c,@screenh,@screenw)
  end

  def run
    begin
      @rendered = 0
      while true
        @rendered+=1
        mesure
        clear
        fetch_and_show
        draw_rest
        delay.times do
          break if watch_for_keypress != '10'  # WTF??
          sleep 1
        end
      end
    ensure
      halt
    end
  end

  def halt
    Ncurses.endwin
    puts('Good bye.')
  end

  def delay
    @delay.to_i
  end

  def faster!
    @delay /= 1.3
    @delay = 10.0 if @delay < 10
  end

  def slower!
    @delay *= 1.3
  end

  private
  def fetch_and_show
    @torrents =
    Torrent.running.each_with_index do |torrent, index|
      draw_torrent_at(torrent, index * 3 +2)
    end.size
    @total_up = Torrent.rate_up
    @total_down = Torrent.rate_down
  end

  def status_for(t)
    "#{t.statusmsg} (#{t.percent_done}%%) " + 
    "down:#{human_transfer(t.rate_down)}/s-(#{human_transfer(t.transferred_down)}) " +
    "up:#{human_transfer(t.rate_up)}/s-(#{human_transfer(t.transferred_up)}) " +
    "(#{t.peers}P/#{t.seeds}S/#{t.distributed_copies}dc)"
  end

  def draw_torrent_at(torrent,pos=0)
    statusmsg = status_for(torrent)
    Ncurses.wattron(@c,Ncurses::A_BOLD)
    thing = @view_filename ? torrent.filename : torrent.short_title
    thing.gsub! /%/, '%%'
    Ncurses.mvwprintw(@c,pos,2,thing)

    Ncurses.wattroff(@c,Ncurses::A_BOLD)
    if statusmsg.length > width 
      @too_small = true
    else
      Ncurses.mvwprintw(@c,pos+1,width-statusmsg.length-2,statusmsg)
    end
  end

  def draw_rest
    if @too_small
      Ncurses.wclear(@c)
      draw_layout
      Ncurses.mvwprintw(@c,height/2,2,'Your window is too small!') 
    else
      draw_layout
    end
    Ncurses.wrefresh(@c)
  end

  def draw_layout
    Ncurses.box(@c,0,0)
    basemsg = "down:#{human_transfer(@total_down)}/s up:#{human_transfer(@total_up)}/s " +
    "rendered #{@rendered} times (#{delay}s delay), keys: [+/-/v/q], last key: (#{@key})"
    Ncurses.mvwprintw(@c,height-1,5,basemsg) 
  end

  def switch_view
    @view_filename = !@view_filename
  end

  def watch_for_keypress
    @key = Ncurses.getch.to_s
    case @key
    when '45'  # +
      faster!
    when '43'  # -
      slower!
    when '113' # q
      exit
    when '118' # v
      switch_view
    end
    @key
  end

end


BTCurses.new.run

