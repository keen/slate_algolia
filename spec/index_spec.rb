require 'spec_helper'

describe Middleman::SlateAlgolia::Index do
  before :each do
    stub_request(:any, %r{.*\.algolia(net\.com|\.net)\/*})
      .to_return(body: '{"hits":[]}')
  end

  after :each do
    WebMock.reset!
  end

  describe 'initialize' do
    it 'creates an Algolia Index with the specified name' do
      expect(Algolia::Index).to receive(:new).with('test')

      Middleman::SlateAlgolia::Index.new(
        application_id: '',
        api_key: '',
        name: 'test'
      )
    end

    it 'uses the defined API keys for the Algolia Index' do
      expect(Algolia).to receive(:init).with(application_id: 'id', api_key: 'key').and_call_original

      Middleman::SlateAlgolia::Index.new(
        application_id: 'id',
        api_key: 'key',
        name: ''
      )
    end
  end

  describe 'flush_queue' do
    it 'calls before_index for each record' do
      dbl = double
      index = Middleman::SlateAlgolia::Index.new(
        application_id: '',
        api_key: '',
        dry_run: false,
        before_index: proc do |record|
          # Verify is not a real method. Just a fake thing on a double
          dbl.verify(record)
        end
      )

      index.queue_object(id: 1)
      index.queue_object(id: 2)

      expect(dbl).to receive(:verify).with(id: 1)
      expect(dbl).to receive(:verify).with(id: 2)

      index.flush_queue
    end

    it 'replaces records via the before_index hook' do
      index = Middleman::SlateAlgolia::Index.new(
        application_id: '',
        api_key: '',
        dry_run: false,
        before_index: proc do |record|
          { id: record[:id] * 2 }
        end
      )

      index.queue_object(id: 1)
      index.queue_object(id: 2)

      expect(index.instance_variable_get('@index')).to receive(:add_objects)
        .with(
          [
            { id: 2 },
            { id: 4 }
          ]
        )

      index.flush_queue
    end

    it 'creates new records if before_index returns an array' do
      index = Middleman::SlateAlgolia::Index.new(
        application_id: '',
        api_key: '',
        dry_run: false,
        before_index: proc do |record|
          [record, { id: record[:id] * 4 }]
        end
      )

      index.queue_object(id: 1)
      index.queue_object(id: 2)

      expect(index.instance_variable_get('@index')).to receive(:add_objects)
        .with(
          [
            { id: 1 },
            { id: 4 },
            { id: 2 },
            { id: 8 }
          ]
        )

      index.flush_queue
    end

    it 'reuses the existing record if the before_index hook has no return' do
      index = Middleman::SlateAlgolia::Index.new(
        application_id: '',
        api_key: '',
        dry_run: false,
        before_index: proc do |record|
          # Wassup!
        end
      )

      index.queue_object(id: 1)
      index.queue_object(id: 2)

      expect(index.instance_variable_get('@index')).to receive(:add_objects)
        .with(
          [
            { id: 1 },
            { id: 2 }
          ]
        )

      index.flush_queue
    end
  end
end
