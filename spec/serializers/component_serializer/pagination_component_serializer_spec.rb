require_relative '../../rails_helper'

RSpec.describe ComponentSerializer::PaginationComponentSerializer do
  let(:page_range_helper_instance) { double('page_range_helper_instance', active_tile_position: 0, last_page: 3, page_range: [1, 2, 3]) }
  let(:page_range_helper) { double('page_range_helper', new: page_range_helper_instance) }
  let(:pagination_hash) {{ start_index: 10, count: 123, results_total: 321, path: 'some_url', query: 'hello' }}
  let(:pagination_hash_no_query) {{ start_index: 10, count: 123, results_total: 321, path: 'some_url' }}
  subject { described_class.new(pagination_hash: pagination_hash, page_range_helper: page_range_helper) }

  it '#current_page' do
    expect(subject.current_page).to eq 1
  end

  context '#total_pages' do
    it 'returns 3' do
      expect(subject.total_pages).to eq 3
    end

    context 'if the current page is greater than the calculated total' do
      it 'returns the current page as the total pages' do
        allow(subject).to receive(:current_page) {5}

        expect(subject.total_pages).to eq 5
      end
    end
  end

  it '#previous_page' do
    expect(subject.previous_page).to eq 0
  end

  describe '#navigation_section_components' do
    it 'creates the correct hash' do
      expected = get_fixture('create_number_cards')

      expect(subject.navigation_section_components.to_yaml).to eq expected
    end

    it 'creates the correct hash with no query url' do
      serializer = described_class.new(pagination_hash: pagination_hash_no_query, page_range_helper: page_range_helper)

      expected = get_fixture('create_number_cards_no_query')

      expect(serializer.navigation_section_components.to_yaml).to eq expected
    end

    it 'there are 6 pages in total' do
      allow(page_range_helper_instance).to receive(:active_tile_position) {2}
      allow(page_range_helper_instance).to receive(:last_page) {6}
      allow(page_range_helper_instance).to receive(:page_range) {[1, 2, 3, 4, 5, 6]}

      allow(subject).to receive(:total_pages) {6}
      allow(subject).to receive(:current_page) {3}

      expected = get_fixture('six_pages')

      expect(subject.navigation_section_components.to_yaml).to eq expected
    end

    context 'there are 100 pages in total' do
      before(:each) do
        allow(subject).to receive(:total_pages) {100}
      end

      it 'the current page is at most 4 pages from the FIRST page' do
        allow(page_range_helper_instance).to receive(:active_tile_position) {1}
        allow(page_range_helper_instance).to receive(:last_page) {8}
        allow(page_range_helper_instance).to receive(:page_range) {[1, 2, 3, 4, 5, 6, 7, 8]}

        allow(subject).to receive(:current_page) {2}

        expected = get_fixture('four_from_first_page')

        expect(subject.navigation_section_components.to_yaml).to eq expected
      end

      it 'the current page is at most 4 pages from the LAST page' do
        allow(page_range_helper_instance).to receive(:active_tile_position) {4}
        allow(page_range_helper_instance).to receive(:last_page) {100}
        allow(page_range_helper_instance).to receive(:page_range) {[93, 94, 95, 96, 97, 98, 99, 100]}

        allow(subject).to receive(:current_page) {97}

        expected = get_fixture('four_from_last_page')

        expect(subject.navigation_section_components.to_yaml).to eq expected
      end

      it 'the current page is somewhere in the middle' do
        allow(page_range_helper_instance).to receive(:active_tile_position) {4}
        allow(page_range_helper_instance).to receive(:last_page) {54}
        allow(page_range_helper_instance).to receive(:page_range) {[47, 48, 49, 50, 51, 52, 53, 54]}

        allow(subject).to receive(:current_page) {51}

        expected = get_fixture('middle')

        expect(subject.navigation_section_components.to_yaml).to eq expected
      end

      it 'when the current page is greater than the total number of pages' do
        allow(page_range_helper_instance).to receive(:active_tile_position) {7}
        allow(page_range_helper_instance).to receive(:last_page) {150}
        allow(page_range_helper_instance).to receive(:page_range) {[143, 144, 145, 146, 147, 148, 149, 150]}

        allow(subject).to receive(:current_page) {150}

        expected = get_fixture('greater_than_total_pages')

        expect(subject.navigation_section_components.to_yaml).to eq expected
      end
    end
  end
end