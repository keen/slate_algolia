require 'oga'
require 'slate_algolia/parser'
require 'slate_algolia/index'

module Middleman
  module SlateAlgolia
    # Base extension orchestration
    class Extension < Middleman::Extension
      option :parsers, {}, 'Custom tag parsers'
      option :dry_run, false, 'Send data to Algolia or not?'
      option :application_id, '', 'Algolia Application ID'
      option :index_name, 'API Docs', 'Name for the Algolia Index'
      option :api_key, '', 'Algolia API Key'
      option :before_index, nil, 'A block to run on each record before it is sent to the index'
      option :filter_deletes, nil, 'A block to run on each record before it is deleted from the index'

      def initialize(app, options_hash = {}, &block)
        super
        merge_parser_defaults(options.parsers)
      end

      def after_build
        parse_content
        index.flush_queue
        index.clean_index
      end

      def index
        @index ||= Index.new(
          application_id: options.application_id,
          api_key: options.api_key,
          name: options.index_name,
          dry_run: options.dry_run,
          before_index: options.before_index,
          filter_deletes: options.filter_deletes
        )
      end

      # rubocop:disable AbcSize, MethodLength
      def parsers
        @parsers ||= {
          pre: lambda do |node, section, page|
            languages = node.get('class').split
            languages.delete('highlight')

            if languages.length

              # if the current language is in the list of language tabs
              code_type = if page.metadata[:page]['language_tabs'].include?(languages.first)
                            :tabbed_code
                          else
                            :permanent_code
                          end

              section[code_type] = {} unless section[code_type]

              section[code_type][languages.first.to_sym] = node.text
            end

            section
          end,

          blockquote: lambda do |node, section, _page|
            section[:annotations] = [] unless section[:annotations]
            section[:annotations].push(node.text)
            section
          end,

          h1: lambda do |node, _section, _page|
            {
              objectID: node.get('id'),
              title: node.text,
              body: ''
            }
          end,

          h2: lambda do |node, _section, _page|
            {
              objectID: node.get('id'),
              title: node.text,
              body: ''
            }
          end
        }
      end
      # rubocop:enable AbcSize, MethodLength

      private

      def parse_content
        app.sitemap.resources.each do |slate_page|
          next unless slate_page.data[:algolia_search]
          content_parser = Parser.new(slate_page, parsers)
          next if content_parser.sections.empty?

          content_parser.sections.each do |section|
            index.queue_object(section)
          end
        end
      end

      def merge_parser_defaults(custom_parsers)
        parsers.merge(custom_parsers)
      end
    end
  end
end
