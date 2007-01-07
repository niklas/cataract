require 'gtktrayicon'
require 'net/http'
require 'rexml/document'
require 'yaml'

class NotificationAreaTooltip
  attr_accessor :timeout
  attr_accessor :id

  def initialize
    @timeout = 0
    @wantx = 0
    @wanty = 0
    @win = nil
    @id = nil
  end

  def create_window
    @win ||= Gtk::Window.new(Gtk::Window::POPUP)
    @win.title = "gtk-tooltips"
    @win.border_width = 9
    #@win.resizeable = false
    #@win.set_default_size(100,400)
    @win.set_events(Gdk::Event::POINTER_MOTION_MASK)

    @win.signal_connect_after("expose_event") do
      style = @win.style
      size = @win.size
      style.paint_flat_box(
        @win.window, Gtk::STATE_NORMAL, Gtk::SHADOW_OUT, 
        nil, @win, 'tooltip', 0, 0, -1, 1
      )
      style.paint_flat_box(
        @win.window, Gtk::STATE_NORMAL, Gtk::SHADOW_OUT, 
        nil, @win, 'tooltip', 0, size[1]-1, -1, 1
      )
      style.paint_flat_box(
        @win.window, Gtk::STATE_NORMAL, Gtk::SHADOW_OUT, 
        nil, @win, 'tooltip', 0, 0, 1, -1
      )
      style.paint_flat_box(
        @win.window, Gtk::STATE_NORMAL, Gtk::SHADOW_OUT, 
        nil, @win, 'tooltip', size[0]-1, 0, 1, -1
      )
    end

    @win.signal_connect("motion_notify_event") do
      hide_tooltip
    end

    @win.signal_connect("size_request") do |widget,req|
      half_width = req[0] / 2 + 1
      if @wantx < half_width
        @wantx = 0
      elsif @wantx + req[0] > @screen.width + half_width
        @wantx = @screen.width - req.width
      else
        @wantx -= half_width
      end

      if @wanty + req[1] > @screen.height
        # flip tooltip up
        @wanty -= req[1] + @win.height + 8
      end
      @wanty = 0 if @wanty < 0
      @win.move(@wantx,@wanty)
    end

    @screen = @win.screen
    #@win.keep_above = true
    #@win.accept_focus = true
  end

  def show_tooltip(data='fn0rd23')
    populate(data)
    # get mouse position
    pointer = @screen.display.pointer
    @wantx = pointer[1]
    @wanty = pointer[2] +4
    @win.move(@wantx,@wanty)
    @win.ensure_style
    @win.show_all
  end

  def hide_tooltip
    if @win
      @win.destroy
      @win = nil
    end
    @id = nil
  end

  def populate(data)
    create_window
    if data.is_a?(Gtk::Widget)
      @win.add(data)
    else
      @win.add(Gtk::Label.new(data.to_s))
    end
  end
end

class CataractTrayIcon < Gtk::TrayIcon
  def initialize(title="Cataract")
    @title = title
    @fetcher = TorrentFetcher.new
    super(@title)
    populate
    show_all
  end

  def populate
    @popup = NotificationAreaTooltip.new

    event_box = Gtk::EventBox.new
    event_box.visible = false
    event_box.add(Gtk::Label.new(@title))
    event_box.set_events(Gdk::Event::POINTER_MOTION_MASK)
    event_box.signal_connect("motion_notify_event") do |widget,event|
      position = widget.window.origin
      if @popup.id != position
        @popup.id = position
        @popup.show_tooltip(torrent_table)
      end
    end
    event_box.signal_connect("leave_notify_event") do |widget,event|
      position = widget.window.origin
      if @popup.id == position
        @popup.hide_tooltip
      end
    end

    self.add(event_box)
  end

  def torrent_table
    torrents = @fetcher.get_torrents
    return Gtk::Label('no torrents') if !torrents or torrents.size == 0

    tab = Gtk::Table.new(torrents.size,2)
    tab.row_spacings = 6
    tab.column_spacings = 3

    n = 0
    torrents.each do |torrent|
      text = torrent.title || torrent.filename || 'unknown'
      label = Gtk::Label.new(text)
      tab.attach_defaults( label, 0, 1, n, n+1)
      bar = Gtk::ProgressBar.new
      bar.set_fraction(torrent.percent_done.to_f/100)
      bar.text = torrent.status
      tab.attach_defaults( bar, 1, 2, n, n+1 )
      n+=1
    end
    return tab
  end
end

class MockTorrent
  def initialize(rexml)
    @rexml = rexml
  end
  def method_missing(name)
    name = name.to_s.gsub /_/, '-'
    e = @rexml.get_elements(name).first
    e ? e.text : nil
  end
end

class TorrentFetcher
  CONFIG = ENV['HOME'] + '/.cataract.yml'
  def initialize
    unless File.exists?(CONFIG)
      write_default_config
      puts "please edit #{CONFIG} and restart"
      exit
    end
    read_config
  end

  def read_config
    @config = YAML.load(File.open(CONFIG))
  end

  def write_default_config
   conf = {
     'user' => 'username',
     'password' => 'foo',
     'host' => '192.168.1.1',
     'port' => 80
   }
   File.open(CONFIG,'w') do |file|
     file.puts conf.to_yaml
   end
  end

  def fetch_xml
    http = Net::HTTP.new(@config['host'],@config['port'])
    req = Net::HTTP::Get.new '/torrents/watchlist', { 'Accept' => 'application/xml'}
    req.basic_auth @config['user'], @config['password']
    res = http.request(req)
    res.body
  end

  def get_torrents
    xml = fetch_xml
    torrents = []
    REXML::Document.new(xml).root.elements.each do |xmltorrent|
      torrents << MockTorrent.new(xmltorrent)
    end
    return torrents
  end
end

tray = CataractTrayIcon.new
Gtk.main
