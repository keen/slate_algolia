require 'spec_helper'

describe Middleman::SlateAlgolia::Extension do

  ConfigOptions = Struct.new(
    :application_id,
    :api_key,
    :dry_run,
    :parsers,
    :before_index
  )

  defaultOptions = ConfigOptions.new('', '', false, {}, nil)

  before :each do
    Given.fixture 'base'
    @app = Middleman::Fixture.app
    @extension = @app.extensions[:slate_algolia]
    stub_request(:any, /.*\.algolia(net\.com|\.net)\/*/).
        to_return(body: '{"hits":[]}')
  end

  after :each do
    WebMock.reset!
  end

  it 'sets default options' do
    expect(@extension.options.to_h.keys.length).to eq(defaultOptions.size)
#
#    @extension.options.to_h.each do |key, value|
#      expect(@extension.options[key]).to eq(defaultOptions[key]), 
#        "#{key.to_s} was #{value}, should be #{defaultOptions[key]}"
#    end
  end

  describe 'parse_content' do
    it 'parses pages where slate_algolia is true' do
        parser_double = double("Content Parser", :sections => [])
        expect(Middleman::SlateAlgolia::Parser).to receive(:new).and_return(parser_double)
        @extension.send(:parse_content, defaultOptions)
    end

    it 'flushes the queue' do
        expect_any_instance_of(Middleman::SlateAlgolia::Index).to receive(:flush_queue)
        @extension.send(:parse_content, defaultOptions)
    end

    it 'cleans the index' do
        expect_any_instance_of(Middleman::SlateAlgolia::Index).to receive(:clean_index)
        @extension.send(:parse_content, defaultOptions)
    end
  end
end
