=begin rdoc

A library for generating small graphics that are used in the famous Lcars design.

Heavily inspired by the sparklines library http://nubyonrails.topfunky.com 

=end

require 'RMagick'
class Lcars
  class << self
    def plot(options={})
      kind = options.delete(:kind) || :corner
      defaults = {
        :diameter => 42,
        :background_color => 'black',
        :variant => :ne
      }

      # HACK for HashWithIndifferentAccess
      options_sym = Hash.new
      options.keys.each do |key|
        options_sym[key.to_sym] = options[key]
      end
      options_sym  = defaults.merge(options_sym)

      lcars = self.new(kind, options_sym)
      lcars.send kind
    end

     # Writes a graph to disk with the specified filename, or "lcars.png"
    def plot_to_file(filename="lcars.png", data=[], options={})
      File.open( filename, 'wb' ) do |png|
        png << self.plot( data, options)
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
    create_canvas(dia, dia, background_color)
    case variant
    when :n
      @draw.circle(dia2,dia,0,dia)
    when :s
      @draw.circle(dia2,0,dia,0)
    when :w
      @draw.circle(dia,dia2,dia,0)
    when :e
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
