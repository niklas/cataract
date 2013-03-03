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
    if seconds.infinite?
      I18n.translate('helper.eta.never')
    else
      now = Time.now
      distance_of_time_in_words(now, now + seconds)
    end
  end
end
