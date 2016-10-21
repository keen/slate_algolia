require 'oga'

module Middleman
  module SlateAlgolia
    class Parser

      def initialize(middleman_page, parsers)
        @middleman_page = middleman_page
        @content = Oga.parse_html(middleman_page.render({:layout => false}, {current_page: middleman_page }))
        @parsers = parsers
        generate_sections
      end

      def sections
        @sections ||= []
      end

      private

      def generate_sections
        @sections = []
        current_section = {title: 'introduction-header'}

        @content.children.each do |node|
          next unless node.class  == Oga::XML::Element

          if node.name == 'h1' or node.name == 'h2'
            @sections.push(current_section) unless current_section[:title].nil? and current_section[:body].empty?
            current_section = {
              id: node.get('id'),
              title: node.text
            }
          else
            parser = @parsers[node.name.to_sym] || self.method(:default_tag_parser)
            parser.call(node, current_section, @middleman_page)
          end
        end

        @sections.push(current_section)
      end

      def default_tag_parser(node, section, page)
        if section[:body]
          section[:body] += "\n"
        else
          section[:body] = ""
        end

        section[:body] += node.text
      end
    end
  end
end
