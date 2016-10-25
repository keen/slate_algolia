require 'algoliasearch'

module Middleman
  module SlateAlgolia
    # Manages the Index stored in Algolia
    class Index
      def initialize(options)
        @options = options
        @publish = !@options[:dry_run]
        @published = []

        Algolia.init application_id: @options[:application_id],
                     api_key: @options[:api_key]

        @index = Algolia::Index.new(options[:name])
        @queue = []
      end

      def queue_object(data)
        @queue.push(data)

        flush_queue if @queue.length >= 1000
      end

      def clean_index
        old_content = @index.browse['hits'].reject do |hit|
          @published.any? { |entry| entry[:id] == hit['id'] }
        end

        if @publish
          @index.delete_objects(old_content.map { |hit| hit['objectID'] })
        else
          puts "would have deleted #{old_content.size} items if not in dry mode"
        end
      end

      def run_before_index
        return @queue unless @options[:before_index].instance_of?(Proc)

        @queue = @queue.map do |record|
          new_record = @options[:before_index].call(record)
          if new_record
            new_record
          else
            record
          end
        end

        @queue.flatten!
      end

      def flush_queue
        run_before_index

        to_publish = @queue.reject { |obj| obj[:objectID].nil? }

        if @publish
          @index.add_objects(to_publish)
        else
          puts "would have published #{to_publish.size} items if not in dry mode"
        end

        @published.concat(to_publish)
        @queue = []
      end
    end
  end
end
