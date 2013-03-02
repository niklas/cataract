module PathnameAddons
  def self.included(base)
    base.class_eval do
      # we want to do Rails.root / "tmp"
      alias_method :/, :join
      alias_method :start_with?, :starts_with?
    end
  end
  def starts_with?(other)
    to_path.starts_with?(other.to_path)
  end

  def relative_components
    raise "is absolute" if absolute?
    [].tap do |cs|
      this = self
      while this.to_s != '.'
        cs.unshift this.basename.to_s
        this = this.dirname
      end
    end
  end
end

Pathname.send :include, PathnameAddons
