require 'spec_helper'

describe Middleman::SlateAlgolia::Index do

  before :each do
    stub_request(:any, /.*\.algolia(net\.com|\.net)\/*/).
      to_return(body: '{"hits":[]}')
  end

  after :each do
    WebMock.reset!
  end

  describe 'flush_queue' do
    
    it 'calls before_index for each record' do
      dbl = double
      index = Middleman::SlateAlgolia::Index.new({
        application_id: '',
        api_key: '',
        dry_run: false,
        before_index: proc { |record|
          #Verify is not a real method. Just a fake thing on a double
          dbl.verify(record)
        }
      })

      index.queue_object({id: 1})
      index.queue_object({id: 2})

      expect(dbl).to receive(:verify).with({id: 1})
      expect(dbl).to receive(:verify).with({id: 2})

      index.flush_queue
    end

    it 'replaces records via the before_index hook' do
      index = Middleman::SlateAlgolia::Index.new({
        application_id: '',
        api_key: '',
        dry_run: false,
        before_index: proc { |record|
          {id: record[:id] * 2}
        }
      })

      index.queue_object({id: 1})
      index.queue_object({id: 2})

      expect(index.instance_variable_get('@index')).to receive(:add_objects).with([
        {id: 2},
        {id: 4}
      ])

      index.flush_queue
    end

    it 'reuses the existing record if the before_index hook does not return anything' do
      index = Middleman::SlateAlgolia::Index.new({
        application_id: '',
        api_key: '',
        dry_run: false,
        before_index: proc { |record|
          # Wassup!
        }
      })

      index.queue_object({id: 1})
      index.queue_object({id: 2})

      expect(index.instance_variable_get('@index')).to receive(:add_objects).with([
        {id: 1},
        {id: 2}
      ])

      index.flush_queue
    end
  end
end
