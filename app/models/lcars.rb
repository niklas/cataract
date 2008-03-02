=begin rdoc

A library for generating small graphics that are used in the famous Lcars design.

Heavily inspired by the sparklines library http://nubyonrails.topfunky.com 

=end

require 'RMagick'
class Lcars
  class << self
    def plot(options={})
      defaults = {
        :diameter => 42,
        :background_color => 'black',
        :variant => :ne,
        :kind => :corner
      }.with_indifferent_access.merge(options)
      kind = defaults[:kind]
      defaults.delete :controller
      defaults.delete :action

      keystr = defaults.map{|k,v| v}.join '_'

      lcars = self.new(kind, defaults)
      return lcars.send(kind), keystr
    end

     # Writes a graph to disk with the specified filename, or "lcars.png"
    def plot_to_file(filename="lcars.png", options={})
      File.open( filename, 'wb' ) do |png|
        png << self.plot(options)
      end
    end

  end # class methods

  def initialize(kind=:corner,options={})
    @options = options
  end

  def corner
    dia = @options[:diameter].to_f
    delim = Math.sin(Math::PI/4) * dia
    background_color = @options[:background_color]
    create_canvas(dia, dia, background_color)
    variant = @options[:variant].downcase.to_sym
    # draw what later should be hidden
    case variant
    when :ne
      @draw.circle(0,dia,delim,dia-delim)
    when :nw
      @draw.circle(dia,dia,dia-delim,dia-delim)
    when :se
      @draw.circle(0,0,delim,delim)
    when :sw
      @draw.circle(dia,0,dia-delim,delim)
    else
      raise "Illegal variant #{variant}"
    end
    finalize
  end

  def bow 
    dia = @options[:diameter].to_f
    delim = Math.sin(Math::PI/4) * dia
    background_color = @options[:background_color]
    create_canvas(dia, dia, background_color)
    variant = @options[:variant].to_sym
    # draw what later should be hidden
    case variant
    when :ne
      @draw.circle(0,dia,delim,dia-delim)
    when :nw
      @draw.circle(dia,dia,dia-delim,dia-delim)
    when :se
      @draw.circle(0,0,delim,delim)
    when :sw
      @draw.circle(dia,0,dia-delim,delim)
    else
      raise "Illegal variant #{variant}"
    end
    finalize(:negate => true)
  end

  def stump
    dia = @options[:diameter].to_f
    dia2 = dia/2
    background_color = @options[:background_color]
    variant = @options[:variant].to_sym
    case variant
    when :n
      create_canvas(dia, dia2, background_color)
      @draw.circle(dia2,dia,0,dia)
    when :s
      create_canvas(dia, dia2, background_color)
      @draw.circle(dia2,0,dia,0)
    when :w
      create_canvas(dia2, dia, background_color)
      @draw.circle(dia,dia2,dia,0)
    when :e
      create_canvas(dia2, dia, background_color)
      @draw.circle(0,dia2,0,0)
    else
      raise "Illegal variant #{variant}"
    end
    finalize
  end

private
  def create_canvas(w,h,bkg_col)
    @draw = Magick::Draw.new
    @draw.fill('black')
    @canvas = Magick::Image.new(w, h) { self.background_color = bkg_col }
    @canvas.format = "PNG"
    @mask = Magick::Image.new(w,h) { self.background_color= 'white'}
  end

  def finalize(opts={})
    @draw.draw(@mask)
    @mask.matte = false
    @canvas.matte = true
    @mask = @mask.negate if opts[:negate]
    @canvas.composite!(@mask,Magick::CenterGravity, Magick::CopyOpacityCompositeOp)
    @canvas.to_blob
  end
end
