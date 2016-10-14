require 'algoliasearch'

module Middleman
    module SlateAlgolia
        class Index

            def initialize(app_id, api_key, dry_run = false)
                @publish = !dry_run
                @published = []

                Algolia.init :application_id => app_id,
                             :api_key        => api_key

                @index = Algolia::Index.new("API Docs")
                @queue = []
            end

            def queue_object(data)
                @queue.push(data)

                if @queue.length >= 1000
                    flush_queue()
                end
            end

            def clean_index
                old_content = @index.browse['hits'].reject { |hit|
                    @published.any? { |entry| entry[:id] == hit['id'] }
                }

                if @publish
                    @index.delete_objects(old_content.map { |hit| hit['objectID'] })
                else
                    puts "would have deleted #{old_content.size} items if not in dry mode"
                end
            end

            def flush_queue
                to_publish = @queue.reject { |obj| obj[:id].nil? }
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
