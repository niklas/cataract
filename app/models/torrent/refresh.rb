class Torrent

  define_callbacks :refresh

  def self.on_refresh(*a, &block)
    set_callback :refresh, :after, *a, &block
  end

  def refresh
    run_callbacks :refresh
  end

  def refresh!
    logger.debug { "refreshing: #{self}" }
    refresh
    save! if changed?
  end

end
