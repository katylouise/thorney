class SearchService < ApplicationController
  # This class handles all the parameters required for the SearchController and subclasses of PageSerializer::SearchPage
  attr_reader :app_insights_request_id, :search_path, :sanitised_query, :escaped_query, :start_index, :count

  def initialize(app_insights_request_id, search_path, params)
    @app_insights_request_id = app_insights_request_id
    @search_path             = search_path

    @query_parameter = params[:q]
    @sanitised_query = SearchHelper.sanitize_query(query_parameter)
    @escaped_query   = CGI.escape(sanitised_query)[0, 2048]
    @start_index = PaginationHelper.normalize_value(:start_index, params)
    @count = PaginationHelper.normalize_value(:count, params)
  end

  def flash_message
    I18n.t('search_controller.index.flash') if query_parameter&.empty?
  end

  def fetch_description
    Parliament::Request::OpenSearchRequest.configure_description_url(ENV['OPENSEARCH_DESCRIPTION_URL'], app_insights_request_id)
  rescue Errno::ECONNREFUSED => error
    raise StandardError, "There was an error getting the description file from OPENSEARCH_DESCRIPTION_URL environment variable value: '#{ENV['OPENSEARCH_DESCRIPTION_URL']}' - #{error.message}"
  end

  def results
    return @results if @results

    logger.info "Making a search query for '#{sanitised_query}' => '#{escaped_query}'"
    @results = build_request.get({ query: escaped_query, start_index: start_index, count: count })
  end

  def total_results
    results.totalResults
  end

  private

  attr_reader :query_parameter

  def build_request
    headers = {}.tap do |hash|
      hash['Request-Id'] = "#{app_insights_request_id}1" if app_insights_request_id
    end

    Parliament::Request::OpenSearchRequest.new(headers: headers,
                                               builder: Parliament::Builder::OpenSearchResponseBuilder)
  end
end
