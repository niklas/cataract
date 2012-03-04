require 'open3'
class Mlocate
  class << self
    def locate(query={})
      if file = query.delete(:file)
        locate_file file
      else
        raise ArgumentError, "unknown query: #{query.inspect}"
      end
    end

    def locate_file(file)
      run '--basename', '--existing', '--quiet', "\\#{file}"
    end

    private

    def run(*args)
      out, status = Open3.capture2 *(['mlocate', '--limit', '50', '--null'] + args)
      out.split("\0")
    end
  end
end
