module Ferret

  module Analysis
  
    # = PerFieldAnalyzer
    #
    # This PerFieldAnalyzer is a workaround to a memory leak in 
    # ferret 0.11.4. It does basically do the same as the original
    # Ferret::Analysis::PerFieldAnalyzer, but without the leak :)
    # 
    # http://ferret.davebalmain.com/api/classes/Ferret/Analysis/PerFieldAnalyzer.html
    #
    # Thanks to Ben from omdb.org for tracking this down and creating this
    # workaround.
    # You can read more about the issue there:
    # http://blog.omdb-beta.org/2007/7/29/tracking-down-a-memory-leak-in-ferret-0-11-4
    class PerFieldAnalyzer < ::Ferret::Analysis::Analyzer
      def initialize( default_analyzer = StandardAnalyzer.new )
        @analyzers = {}
        @default_analyzer = default_analyzer
      end
            
      def add_field( field, analyzer )
        @analyzers[field] = analyzer
      end
      alias []= add_field
                
      def token_stream(field, string)
        @analyzers.has_key?(field) ? @analyzers[field].token_stream(field, string) : 
        @default_analyzer.token_stream(field, string)
      end
    end
  end


  class Index::Index
    attr_accessor :batch_size
    attr_accessor :logger

    def index_models(models)
      models.each { |model| index_model model }
      flush
      optimize
      close
      ActsAsFerret::close_multi_indexes
    end

    def index_model(model)
      @batch_size ||= 0
      work_done = 0
      batch_time = 0
      logger.info "reindexing model #{model.name}"

      model_count  = model.count.to_f
      model.records_for_rebuild(@batch_size) do |records, offset|
        #records = [ records ] unless records.is_a?(Array)
        batch_time = measure_time {
          records.each { |rec| self << rec.to_doc if rec.ferret_enabled?(true) }
        }.to_f
        work_done = offset.to_f / model_count * 100.0 if model_count > 0
        remaining_time = ( batch_time / @batch_size ) * ( model_count - offset + @batch_size )
        logger.info "reindex model #{model.name} : #{'%.2f' % work_done}% complete : #{'%.2f' % remaining_time} secs to finish"
      end
    end

    def measure_time
      t1 = Time.now
      yield
      Time.now - t1
    end

  end


  # add marshalling support to SortFields
  class Search::SortField
    def _dump(depth)
      to_s
    end

    def self._load(string)
      case string
        when /<DOC(_ID)?>!/         : Ferret::Search::SortField::DOC_ID_REV
        when /<DOC(_ID)?>/          : Ferret::Search::SortField::DOC_ID
        when '<SCORE>!'             : Ferret::Search::SortField::SCORE_REV
        when '<SCORE>'              : Ferret::Search::SortField::SCORE
        when /^(\w+):<(\w+)>(!)?$/ : new($1.to_sym, :type => $2.to_sym, :reverse => !$3.nil?)
        else raise "invalid value: #{string}"
      end
    end
  end

  # add marshalling support to Sort
  class Search::Sort
    def _dump(depth)
      to_s
    end

    def self._load(string)
      # we exclude the last <DOC> sorting as it is appended by new anyway
      if string =~ /^Sort\[(.*?)(<DOC>(!)?)?\]$/
        sort_fields = $1.split(',').map do |value| 
        value.strip!
          Ferret::Search::SortField._load value unless value.blank?
        end
        new sort_fields.compact
      else
        raise "invalid value: #{string}"
      end
    end
  end

end
