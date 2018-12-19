require_relative '../../rails_helper'

RSpec.describe PaginationHelper, type: :helper do
  describe '#generate_hash' do
    let (:path) { '/search' }
    context 'start_index and count are present and set correctly' do
      it 'generates a hash with the expected values' do
        params = { start_index: '11', count: '20' }
        expected = {
          start_index: 11,
          count: 20,
          results_total: 500,
          path: '/search',
          query: 'biscuits'
        }

        expect(described_class.generate_hash(params: params, results_total: 500, path: path, query: 'biscuits')).to eq(expected)
      end
    end

    context 'start_index and count are not present' do
      it 'generates a hash with the expected values' do
        params = {}
        expected = {
          start_index: 1,
          count: 10,
          results_total: 500,
          path: '/search',
          query: 'biscuits'
        }

        expect(described_class.generate_hash(params: params, results_total: 500, path: path, query: 'biscuits')).to eq(expected)
      end
    end

    context 'start_index and count are set incorrectly to strings' do
      it 'generates a hash with the expected values' do
        params = { start_index: 'foo', count: 'bar' }
        expected = {
          start_index: 1,
          count: 10,
          results_total: 500,
          path: '/search',
          query: 'biscuits'
        }

        expect(described_class.generate_hash(params: params, results_total: 500, path: path, query: 'biscuits')).to eq(expected)
      end
    end
  end
end