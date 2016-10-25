require 'oga'

module Middleman
  module SlateAlgolia
    # Parses the HTML and translates it to an Index Record format
    class Parser
      def initialize(middleman_page, parsers)
        @middleman_page = middleman_page
        @page = Oga.parse_html(
          middleman_page.render(
            {},
            { current_page: middleman_page }
          )
        )
        @parsers = parsers
        generate_sections
      end

      def sections
        @sections ||= []
      end

      private

      def content
        @content ||= @page.css('.content').first
      end

      def generate_sections
        current_section = {
          objectID: 'intro',
          title: 'introduction-header',
          body: ''
        }

        content.children.each do |node|
          next unless node.class == Oga::XML::Element
          current_section = parse_node(node, current_section, @middleman_page)
        end

        sections.push(current_section)
      end

      def handle_new_section(node, current_section)
        if node.name == 'h1' || node.name == 'h2'
          unless current_section[:title].nil? &&
                 current_section[:body].empty?

            sections.push(current_section)
          end

          {}
        else
          current_section
        end
      end

      def parse_node(node, section, page)
        section = handle_new_section(node, section)
        parser = @parsers[node.name.to_sym] ||
                 method(:default_tag_parser)

        parser.call(node, section, page)
      end

      def default_tag_parser(node, section, _page)
        if section[:body]
          section[:body] += '\n'
        else
          section[:body] = ''
        end

        section[:body] += node.text

        section
      end
    end
  end
end
