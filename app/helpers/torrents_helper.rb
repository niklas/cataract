module TorrentsHelper

  def human_bytes(bytes)
    return if bytes.blank?
    number_to_human_size(bytes).sub(/ytes$/,'')
  end

  def human_bytes_rate(bytes)
    return if bytes.blank?
    human_bytes(bytes) + '/s'
  end

  def time_left_in_words(seconds)
    now = Time.now
    distance_of_time_in_words(now, now + seconds)
  rescue FloatDomainError => e
    I18n.translate('helper.eta.never')
  end

end
