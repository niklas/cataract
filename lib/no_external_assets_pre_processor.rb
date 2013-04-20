class NoExternalAssetsPreProcessor < Sprockets::Processor
  DroidSans = Rails.root.join('lib/assets/stylesheets/droid_sans.css')
  def evaluate(context, locals)
    data.gsub  %r~@import\s*url\("(//[^"]+)"\);~ do |match|
      Rails.logger.debug { "#{self.class.name} found external asset: #{match.inspect}" }
      case url = $1
      when '//fonts.googleapis.com/css?family=Droid+Sans:400,700'
        File.read(DroidSans)
      else
        match
      end
    end
  end
end

