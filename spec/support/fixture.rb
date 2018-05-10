module Middleman
  module Fixture
    class << self
      def app(&block)
        ENV['MM_ROOT'] = Given::TMP

        if Middleman::Application.respond_to?(:new)
          app = Middleman::Application.new do
            instance_eval(&block) if block
          end
        end

        app
      end
    end
  end
end
