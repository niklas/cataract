class RemoteTorrent
  include ActiveModel::Model

  attr_accessor :title
  attr_accessor :uri
  attr_accessor :size
  attr_accessor :age
  attr_accessor :seeds
  attr_accessor :magnet
  validates_presence_of :title, :uri

  def id
    @id ||= extract_id_from(magnet)
  end

  private

  def extract_id_from(source)
    if source =~ /([A-F0-9]{40})/
      $1
    end
  end
end
