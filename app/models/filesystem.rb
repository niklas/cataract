module Filesystem
  def basename
    path? && path.basename.to_s
  end

  # Pathnames of subdirectories
  def sub_directories
    glob('*')
      .select { |dir| File.directory? dir }
      .sort
      .map    { |dir| Pathname.new(dir) }
  end

  def glob(pattern)
    Dir[ path/pattern ]
  end

  module PathnameSerializer
    def self.load(text)
      return unless text.present?
      Pathname.new(text)
    end

    def self.dump(pathname)
      pathname.to_s
    end
  end

  def path?
    PathnameSerializer.dump(path).present?
  end

  def relative_path?
    PathnameSerializer.dump(relative_path).present?
  end

  def self.included(base)
    base.class_eval do

      if column_names.include?('relative_path')
        serialize :relative_path, PathnameSerializer
        scope :by_relative_path, lambda {|p| where(relative_path: PathnameSerializer.dump(p)) }
      end

      if column_names.include?('path')
        serialize :path, PathnameSerializer
        validates :path, uniqueness: true, presence: true
        scope :by_path, lambda {|p| where(path: PathnameSerializer.dump(p)) }
      end

      validates :name, presence: true

      extend SingletonMethods
    end
  end

  # FIXME does not .serialize handles this?
  #       maybe conflict with ancestry
  def path=(new_path)
    if new_path.is_a?(Pathname)
      super new_path
    elsif new_path.blank?
      super(nil)
    else
      super Pathname.new(new_path.to_s)
    end
  end

  def relative_path=(new_path)
    if new_path.is_a?(Pathname)
      super new_path
    elsif new_path.blank?
      super(nil)
    else
      super Pathname.new(new_path.to_s)
    end
  end

  module SingletonMethods
    def validates_predicate attribute, meth
      word = meth.to_s.sub(/\?$/,'')
      validates_each attribute do |record, attr, value|
        if value.respond_to?(meth)
          record.errors.add attr, "is not #{word}" unless value.send(meth)
        end
      end
    end

  end
end
