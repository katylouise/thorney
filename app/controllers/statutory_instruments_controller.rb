class StatutoryInstrumentsController < ApplicationController
  # Controller rendering statutory instruments index and show pages
  before_action :build_request, :data_check

  ROUTE_MAP = {
    index: proc { ParliamentHelper.parliament_request.statutory_instrument_index },
    show:  proc { |params| ParliamentHelper.parliament_request.statutory_instrument_by_id.set_url_params({ statutory_instrument_id: params[:statutory_instrument_id] }) }
  }.freeze

  def index
    @statutory_instruments, blank_nodes = FilterHelper.filter(@api_request, 'StatutoryInstrumentPaper', ::Grom::Node::BLANK)
    @count = blank_nodes.select { |node| node.respond_to?(:count) }
    list_components = LaidThingListComponentsFactory.sort_and_build_components(statutory_instruments: @statutory_instruments)

    heading = ComponentSerializer::Heading1ComponentSerializer.new(heading: I18n.t('statutory_instruments.index.title'))

    pagination_hash = {
      start_index:   params[:start_index],
      count:         params[:count],
      results_total: @count
    }

    serializer = PageSerializer::ListPageSerializer.new(request: request, heading_component: heading, list_components: list_components, data_alternates: @alternates)

    render_page(serializer)
  end

  def show
    @statutory_instrument = FilterHelper.filter(@api_request, 'StatutoryInstrumentPaper')
    @statutory_instrument = @statutory_instrument.first

    serializer = PageSerializer::StatutoryInstrumentsShowPageSerializer.new(request: request, statutory_instrument: @statutory_instrument, data_alternates: @alternates)

    render_page(serializer)
  end
end
