module ComponentSerializer
  class PaginationComponentSerializer
    def initialize(pagination_hash:, page_range_helper: PageRangeHelper)
      @start_index   = pagination_hash[:start_index]
      @count         = pagination_hash[:count]
      @results_total = pagination_hash[:results_total]
      @path     = pagination_hash[:path]
      @query = pagination_hash[:query] if pagination_hash[:query]

      @page_range_helper = page_range_helper.new(self)
    end

    def navigation_section_components
      data = {}.tap do |hash|
        hash[:active_tile]  = page_range_helper.active_tile_position + 1
        hash[:previous_url] = previous_url unless current_page == 1
        hash[:next_url]     = next_url unless current_page == page_range_helper.last_page
        hash[:components]   = create_number_cards
      end

      ComponentSerializer::CardComponentSerializer.new(name: 'navigation__number__number', data: data).to_h
    end

    def current_page
      @current_page ||= (@start_index / @count + 1)
    end

    def total_pages
      return @total_pages if @total_pages

      calculated_total = (@results_total.to_f / @count).ceil

      return @total_pages = current_page if current_page > calculated_total

      @total_pages = calculated_total
    end

    def previous_page
      current_page - 1
    end

    private

    attr_reader :page_range_helper

    def next_page
      current_page + 1
    end

    # Generate a start index for a given page number
    def start_index(page)
      (page - 1) * @count + 1
    end

    def number_card_url(page)
      create_page_url(start_index(page))
    end

    def previous_url
      create_page_url(start_index(previous_page))
    end

    def next_url
      create_page_url(start_index(next_page))
    end

    def create_number_cards
      page_range_helper.page_range.map do |page|
        data = {}.tap do |hash|
          hash[:url]         = number_card_url(page)
          hash[:number]      = page
          hash[:total_count] = "of #{total_pages}"
          hash[:active]      = true if page == current_page
        end

        ComponentSerializer::CardComponentSerializer.new(name: 'navigation__number__card', data: data).to_h
      end
    end

    def create_page_url(start_index)
      if @query
        "#{@path}?count=#{@count}&q=#{@query}&start_index=#{start_index}"
      else
        "#{@path}?count=#{@count}&start_index=#{start_index}"
      end
    end
  end
end
