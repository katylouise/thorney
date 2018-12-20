require_relative '../rails_helper'

RSpec.describe SearchService, vcr: true do
  let(:params) { { q: 'banana', start_index: '21', count: '10' } }
  let(:subject) { described_class.new(123, '/search', params) }

  context 'methods' do
    before(:each) do
      allow(Parliament::Request::OpenSearchRequest).to receive(:configure_description_url)
    end

    it '#sanitised_query' do
      expect(subject.sanitised_query).to eq 'banana'
    end

    context '#flash_message' do
      it 'if query is nil' do
        params[:q] = nil

        expect(subject.flash_message).to eq nil
      end

      it 'if query is empty' do
        params[:q] = ''

        expect(subject.flash_message).to eq I18n.t('search_controller.index.flash')
      end
    end

    it '#escaped_query' do
      params[:q] = 'hello there'

      expect(subject.escaped_query).to eq 'hello+there'
    end

    context 'fetch_description' do
      it 'successful fetching' do
        subject.fetch_description

        expect(Parliament::Request::OpenSearchRequest).to have_received(:configure_description_url).with(ENV['OPENSEARCH_DESCRIPTION_URL'], 123)
      end

      it 'errors' do
        allow(Parliament::Request::OpenSearchRequest).to receive(:configure_description_url) { raise raise Errno::ECONNREFUSED }

        expect{ subject.fetch_description }.to raise_error(StandardError, "There was an error getting the description file from OPENSEARCH_DESCRIPTION_URL environment variable value: '#{ENV['OPENSEARCH_DESCRIPTION_URL']}' - Connection refused")
      end
    end
  end

  context 'external requests' do
    it 'sends the expected headers to the search API' do
      subject.fetch_description
      subject.results

      expect(WebMock).to have_requested(:get, ENV['OPENSEARCH_DESCRIPTION_URL']).with(headers: {'Accept' => ['*/*', 'application/opensearchdescription+xml']})
      expect(WebMock).to have_requested(:get, 'https://api-parliament-uk.azure-api.net/Staging/search?count=10&q=banana&start=21').with(headers: {'Accept'=>['*/*', 'application/atom+xml']})
    end
  end
end
