# encoding: utf-8
module PathOnFilesystem
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
    Dir[ full_path/pattern ]
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

  def self.included(base)
    base.class_eval do

      if column_names.include?('relative_path')
        serialize :relative_path, PathnameSerializer
        scope :by_relative_path, lambda {|p| where(relative_path: PathnameSerializer.dump(p)) }
        include RelativePathInstanceMethods
      end

      if column_names.include?('path')
        serialize :path, PathnameSerializer
        validates :path, uniqueness: true, presence: true
        scope :by_path, lambda {|p| where(path: PathnameSerializer.dump(p)) }
        include PathInstanceMethods
      end

      validates :name, presence: true

    end
  end

  module PathInstanceMethods
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

    def path?
      PathnameSerializer.dump(path).present?
    end

    # Directory#full_path thx to ancestry, Disk#path stays for the time being
    def full_path
      path
    end
  end

  module RelativePathInstanceMethods
    def relative_path=(new_path)
      if new_path.is_a?(Pathname)
        super new_path
      elsif new_path.blank?
        super(nil)
      else
        super Pathname.new(new_path.to_s)
      end
    end

    def relative_path?
      PathnameSerializer.dump(relative_path).present?
    end
  end


end
