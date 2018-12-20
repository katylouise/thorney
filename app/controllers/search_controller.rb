class SearchController < ApplicationController
  def index
    # Show the index page if there is no query or an empty string is passed
    return render_page(PageSerializer::SearchPage::LandingPageSerializer.new(request: request, flash_message: search_service.flash_message)) unless search_service.sanitised_query.present?

    search_service.fetch_description

    begin
      pagination_hash = PaginationHelper.generate_hash(params: params, results_total: search_service.total_results, path: search_path, query: search_service.escaped_query)
      serializer = PageSerializer::SearchPage::ResultsPageSerializer.new(request: request, query: search_service.sanitised_query, results: search_service.results, pagination_hash: pagination_hash)

      return render_page(serializer)
    rescue Parliament::ServerError => e
      logger.warn "Server error caught from search request: #{e.message}"
      serializer = PageSerializer::SearchPage::ResultsPageSerializer.new(request: request, query: search_service.sanitised_query)

      return render_page(serializer)
    end
  end

  def opensearch
    description_file = <<~XML
      <?xml version="1.0" encoding="UTF-8"?>
      <OpenSearchDescription xmlns="http://a9.com/-/spec/opensearch/1.1/">
        <ShortName>#{I18n.t('search_controller.opensearch.short_name')}</ShortName>
        <Description>Search #{I18n.t('search_controller.opensearch.short_name')} online content</Description>
        <Image height="16" width="16" type="image/x-icon">#{root_url}favicon.ico</Image>
        <Url type="text/html" template="#{search_url}?q={searchTerms}&amp;start_index={startIndex?}&amp;count={count?}" />
      </OpenSearchDescription>
    XML

    render xml: description_file, content_type: 'application/opensearchdescription+xml', layout: false
  end

  private

  def search_service
    @search_service ||= SearchService.new(request.env['ApplicationInsights.request.id'], search_path, params)
  end
end
