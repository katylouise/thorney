module PaginationHelper
  DEFAULTS = {
    start_index: 1,
    count:       10
  }

  class << self
    def generate_hash(params:, results_total:, path:, query: nil)
      {
        start_index:   normalize_value(:start_index, params),
        count:         normalize_value(:count, params),
        results_total: results_total,
        path:          path,
        query:         query
      }
    end

    def normalize_value(symbol, params)
      value = params.fetch(symbol, '').empty? ? nil : convert_to_integer(params[symbol])

      value || DEFAULTS[symbol]
    end

    private

    def convert_to_integer(value)
      value.to_i.to_s == value ? value.to_i : nil
    end
  end
end
