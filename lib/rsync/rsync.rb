require 'singleton'
require 'open3'
class Rsync
  include Singleton
  def self.copy(from,to,&block)
    Open3.popen3(command(from,to)) do |stdin, stdout, stderr|
      stdin.close_write
      parse(stdout,&block)
    end
  end

  def self.command(from,to)
    "rsync -aP '#{from.gsub(/'/,'\'')}' '#{to.gsub(/'/,'\'')}'"
  end

  def self.parse(io)
    total = nil
    left = nil
    current_file = nil
    io.sync = true
    while lines = io.readline("\r")
      lines.split(/\n/).each do |line|
        line.chomp!
        debug "[#{line}]"
        case line
        when %r~(\d+) files to consider~
          total = $1.to_f
          left = total
        #        54349 100%   51.83MB/s    0:00:00 (xfer#2, to-check=6731/6734)
        when %r~^\s+\d+\s+\d+%.+\(xfer#(\d+), to-check=(\d+)/(\d+)\)$~
          part =           nil
          xfer =                        $1.to_f
          left =                                        $2.to_f
          total =                                             $3.to_f
        #        32768  60%   31.25MB/s    0:00:00
        when %r~^\s+\d+\s+(\d+)%~
          part = $1.to_f
        when %r~^created directory~
          next
        when %r~\s*\d+\s+files\.\.\.~
          next
        when %r~building file list~
          total = nil
        else
          current_file = line
          left -= 1.0 if line =~ %r(/$) and left
          debug "else: #{line}"
        end
        if total && left
          progress_percent = 100.0 * (total - left) / total
          progress_percent += part/total if part
          yield progress_percent, current_file, (part || 0)
        end
      end
    end
  rescue EOFError
    yield 100.0, '[done]', 0
  end

  def self.debug?
    @debug
  end
  def self.debug!
    @debug = true
  end
  def self.debug(text)
    puts "RSYNC: #{text}" if debug?
  end
end
