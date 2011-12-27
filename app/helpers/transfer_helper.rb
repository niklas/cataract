module TransferHelper

  def human_bytes(kb, rate=true)
    number_to_human_size(kb.kilobytes)
      .sub(/ytes$/,'') + (rate ? '/s' : '')
  end

  def human_bytes_rate(kb)
    human_bytes(kb, true)
  end

  def lala_human_bytes(b)
    human_transfer(b/1024,false)
  end



end
