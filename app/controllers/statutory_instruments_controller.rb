class StatutoryInstrumentsController < ApplicationController
  # Controller rendering statutory instruments index and show pages
  before_action :build_request, :data_check

  ROUTE_MAP = {
    index: proc do |params|
      limit  = (params[:count] || 10).to_i
      offset = (params[:start_index] || 1).to_i

      if offset == 1
        ParliamentHelper.parliament_request.statutory_instrument_page_one.set_url_params({ limit: limit, offset: offset - 1 })
      elsif offset == 11
        ParliamentHelper.parliament_request.statutory_instrument_page_two.set_url_params({ limit: limit, offset: offset - 1 })
      elsif offset == 21
        ParliamentHelper.parliament_request.statutory_instrument_page_three.set_url_params({ limit: limit, offset: offset - 1 })
      end
    end,
    show:  proc {|params| ParliamentHelper.parliament_request.statutory_instrument_by_id.set_url_params({ statutory_instrument_id: params[:statutory_instrument_id] })}
  }.freeze

  def index
    @statutory_instruments, blank_nodes = FilterHelper.filter(@api_request, 'StatutoryInstrumentPaper', ::Grom::Node::BLANK)

    total_results_node = blank_nodes.select {|node| node.respond_to?(:count)}.first
    @total_results     = total_results_node ? total_results_node.count.to_i : 0

    list_components = LaidThingListComponentsFactory.sort_and_build_components(statutory_instruments: @statutory_instruments)

    heading = ComponentSerializer::Heading1ComponentSerializer.new(heading: I18n.t('statutory_instruments.index.title'))

    pagination_hash = PaginationHelper.generate_hash(params: params, results_total: @total_results, path: request.path)

    serializer = PageSerializer::ListPageSerializer.new(request: request, heading_component: heading, list_components: list_components, data_alternates: @alternates, pagination_hash: pagination_hash)

    render_page(serializer)
  end

  def show
    @statutory_instrument = FilterHelper.filter(@api_request, 'StatutoryInstrumentPaper')
    @statutory_instrument = @statutory_instrument.first

    serializer = PageSerializer::StatutoryInstrumentsShowPageSerializer.new(request: request, statutory_instrument: @statutory_instrument, data_alternates: @alternates)

    render_page(serializer)
  end
end
