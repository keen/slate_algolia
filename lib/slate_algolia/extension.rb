require 'oga'
require 'slate_algolia/parser'
require 'slate_algolia/index'

module Middleman
  module SlateAlgolia
    class Extension < Middleman::Extension
      option :parsers, {}, 'Custom tag parsers'
      option :dry_run, false, 'Send data to Algolia or not?'
      option :application_id, '', 'Algolia Application ID'
      option :api_key, '', 'Algolia API Key'
      option :before_index, nil, 'A block to run on each record before it is sent to the index'

      def initialize(app, options_hash={}, &block)
        super

        # Need to scope it so it's available in the after_build block
        opts = options

        app.after_build do |builder|
          parse_content(opts)
        end
      end

      private

      def parse_content(options)
        app.sitemap.where(:algolia_search.equal => true).all.each do |slate_page|
          content_parser = Parser.new(slate_page, options.parsers)

          if content_parser.sections.length > 0
            index = Index.new({
              application_id: options.application_id,
              api_key: options.api_key,
              dry_run: options.dry_run,
              before_index: options.before_index
            })

            content_parser.sections.each do |section|
              index.queue_object(section)
            end

            index.flush_queue
            index.clean_index
          end
        end
      end

      def parser_defaults
        {
          pre: -> (node, section, page) do 
            languages = node.get('class').split
            languages.delete('highlight')

            if languages.length

              # if the current language is in the list of language tabs
              if page.metadata[:page]['language_tabs'].include?(languages.first)
                code_type = :tabbed_code
              else
                code_type = :permanent_code
              end

              unless section[code_type]
                section[code_type] = {}
              end

              section[code_type][languages.first.to_sym] = node.text
            end
          end,

          blockquote: -> (node, section, page) do
            unless section[:annotations]
              section[:annotations] = []
            end

            section[:annotations].push(node.text)
          end
        }
      end

      def set_parser_defaults(custom_parsers)
        parser_defaults.merge(custom_parsers)
      end
    end
  end
end
