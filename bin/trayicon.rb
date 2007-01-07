require 'gtktrayicon'

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
    #@win.border = 3
    #@win.resizeable = false
    @win.set_default_size(100,400)
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
    @win.add(Gtk::Label.new(data.to_s))
  end
end


tray = Gtk::TrayIcon.new("Cataract")
popup = NotificationAreaTooltip.new
event_box = Gtk::EventBox.new
event_box.visible = false
event_box.add(Gtk::Label.new("Cataract"))
event_box.set_events(Gdk::Event::POINTER_MOTION_MASK)
event_box.signal_connect("motion_notify_event") do |widget,event|
  position = widget.window.origin
  if popup.id != position
    popup.id = position
    popup.show_tooltip("foo")
  end
end
event_box.signal_connect("leave_notify_event") do |widget,event|
  position = widget.window.origin
  if popup.id == position
    popup.hide_tooltip
  end
end
tray.add(event_box)
tray.show_all

Gtk.main
