Pathname.class_eval do
  # we want to do Rails.root / "tmp"
  alias_method :/, :join
  def starts_with?(other)
    to_path.starts_with?(other.to_path)
  end
  alias_method :start_with?, :starts_with?

  def split_first
    if m = to_path.match( %r~^([^/]+)/(.+)$~ )
      [ m[1], self.class.new(m[2]) ]
    else
      raise "cannot split first"
    end
  end

  def more_than_basename?
    self != basename
  end
end
