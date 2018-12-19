require_relative '../../rails_helper'

RSpec.describe PaginationHelper, type: :helper do
  describe '#generate_hash' do
    context 'start_index and count are present and set correctly' do
      it 'generates a hash with the expected values' do
        params = { start_index: 11, count: 40 }
        path = '/search'

      end
    end

    context 'start_index and count are not present' do

    end

    context 'start_index and count are set incorrectly to strings' do

    end
  end

end