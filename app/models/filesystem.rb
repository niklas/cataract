module Filesystem
  def basename
    path.present? && path.basename.to_s
  end

  def name
    read_attribute(:name) || basename || ''
  end

  # Pathnames of subdirectories
  def sub_directories
    glob('*')
      .select { |dir| File.directory? dir }
      .sort
      .map    { |dir| ::Pathname.new(dir) }
  end

  def glob(pattern)
    Dir[ path/pattern ]
  end

  class Pathname
    def load(text)
      return unless text.present?
      ::Pathname.new(text)
    end

    def dump(pathname)
      pathname.to_s
    end
  end

  def path?
    read_attribute(:path).present?
  end

  def exist?
    path.present? && path.exist?
  end

  def self.included(base)
    base.class_eval do
      serialize :path, Pathname.new

      validates_each :path do |record, attr, value|
        record.errors.add attr, "is not absolute" unless value.absolute?
      end
      validates :path, uniqueness: true, presence: true
      validates :name, presence: true
    end
  end

  # FIXME does not .serialize handles this?
  #       maybe conflict with ancestry
  def path=(new_path)
    if new_path.is_a?(::Pathname)
      super new_path
    elsif new_path.blank?
      super(nil)
    else
      super ::Pathname.new(new_path.to_s)
    end
  end
end
