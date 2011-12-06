class Move
  include ActiveModel::Validations
  include ActiveModel::Serialization
  include ActiveModel::AttributeMethods
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :attributes
  def initialize(attributes)
    @attributes = attributes
  end

  %w(torrent_id target_id).each do |attr|
    define_method :"#{attr}" do
      @attributes[attr]
    end
    define_method :"#{attr}=" do |v|
      @attributes[attr] = v
    end
  end

  validates_numericality_of :torrent_id
  validates_numericality_of :target_id
 
  def persisted?
    false
  end

  def save
    MoveJob::Queue.enqueue("Move.run", attributes)
  end

  def self.run(attributes)
    new(attributes).run
  end

  def run
    Rails.logger.debug { "Running with #{attributes.inspect}" }
  end

end
