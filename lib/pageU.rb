# frozen_string_literal: true

require_relative "pageU/version"

module PageU
  class Error < StandardError; end

  DEFAULT_PAGE_LIMIT = 10

  def pages(records:, url:, params:)
    paginate = Paginate.new(records: records,
                            url: url,
                            limit: limit,
                            params: params)
    paginate.pages
  end

  def limit
    return self.class::PAGE_LIMIT if defined? self.class::PAGE_LIMIT

    DEFAULT_PAGE_LIMIT
  end
end
