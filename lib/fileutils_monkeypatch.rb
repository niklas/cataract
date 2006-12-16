# 
# = fileutilspatch.rb
# 
# * monkey-patches the Fileutils.mv method to move file korrect between different FIlesystems
# * the Veriso in Ubuntu Dapper didn*t get this update, but the edgy's does.
#
# by Niklas Hofer for Cataract
#
module FileUtils

  def mv(src, dest, options = {})
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
  module_function :mv

  alias move mv
  module_function :move

end
