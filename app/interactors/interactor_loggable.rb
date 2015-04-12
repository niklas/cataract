module InteractorLoggable
  def debug(&block)
    if context.logger
      context.logger.debug &block
    end
  end
end
