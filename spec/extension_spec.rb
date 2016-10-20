require 'spec_helper'

describe Middleman::SlateAlgolia::Extension do
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
    expect(@extension.options.to_h.keys.length).to eq(4)

    expect(@extension.options.api_key).to eq('')
    expect(@extension.options.application_id).to eq('')
    expect(@extension.options.dry_run).to eq(false)
    expect(@extension.options.parsers).to eq({})
  end

  describe 'parse_content' do
    it 'parses pages where slate_algolia is true' do
        parser_double = double("Content Parser", :sections => [])
        expect(Middleman::SlateAlgolia::Parser).to receive(:new).and_return(parser_double)
        @extension.send(:parse_content, '', '', false, {})
    end

    it 'flushes the queue' do
        expect_any_instance_of(Middleman::SlateAlgolia::Index).to receive(:flush_queue)
        @extension.send(:parse_content, '', '', false, {})
    end

    it 'cleans the index' do
        expect_any_instance_of(Middleman::SlateAlgolia::Index).to receive(:clean_index)
        @extension.send(:parse_content, '', '', false, {})
    end
  end
end
