# 
# = fileutils_monkeypatch.rb
# 
# * monkey-patches the Fileutils.mv method to move file correctly between different Filesystems
# * the version in Ubuntu Dapper didn't get this update, but the Edgy's did.
#
# by Niklas Hofer for Cataract
#
require 'fileutils'

module FileUtils

  def bad_mv(src, dest, options = {})
    fu_check_options options, :force, :noop, :verbose
    fu_output_message "mv#{options[:force] ? ' -f' : ''} #{[src,dest].flatten.join ' '}" if options[:verbose]
    return if options[:noop]
    fu_each_src_dest(src, dest) do |s, d|
      destent = Entry_.new(d, nil, true)
      begin
        if destent.exist?
          if destent.directory?
            raise Errno::EEXIST, dest
          else
            destent.remove_file if rename_cannot_overwrite_file?
          end
        end
        begin
          File.rename s, d
        rescue Errno::EXDEV
          copy_entry s, d, true
          File.unlink s    # TODO this is the critical part
        end
      rescue SystemCallError
        raise unless options[:force]
      end
    end
  end
  def mv(src, dest, options = {})
    fu_check_options options, :force, :noop, :verbose
    return if options[:noop]
    raise Errno::EEXIST, dest if File.exist?(dest)
    raise Errno::ENOENT, src unless File.exist?(src)
    good_dest = dest.gsub(/'/, '\'')
    good_src  =  src.gsub(/'/, '\'')
    mess = `/bin/mv -- '#{good_src}' '#{good_dest}' 2>&1`
    unless $? == 0
      raise SystemCallError, (mess.empty? ? $?.to_s : mess)
      #          question mark hell ??? ^^^
    end
  end
  module_function :mv

  alias move mv
  module_function :move

end
