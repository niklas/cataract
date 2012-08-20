module TorrentsHelper

  def human_bytes(bytes)
    return if bytes.blank?
    number_to_human_size(bytes).sub(/ytes$/,'')
  end

  def human_bytes_rate(bytes)
    return if bytes.blank?
    human_bytes(bytes) + '/s'
  end

end
