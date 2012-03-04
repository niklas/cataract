require 'open3'
class Mlocate
  class << self
    def locate(query={})
      if filename = query.delete(:file)
        file filename
      else
        raise ArgumentError, "unknown query: #{query.inspect}"
      end
    end

    def file(name)
      run '--basename', "\\#{name}"
    end

    private

    def run(*args)
      out, status = Open3.capture2 *(['mlocate', '--limit', '50', '--null', '--existing', '--quiet'] + args)
      out.split("\0")
    end
  end
end
