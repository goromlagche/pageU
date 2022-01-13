# frozen_string_literal: true

class Paginate
  def initialize(records:, url:, limit:, params:)
    @records = records
    @url = url
    @limit = limit
    @params = params
  end

  def pages
    {
      records: paginated_records,
      next_url: pagination_url(direction: "next"),
      prev_url: pagination_url(direction: "prev")
    }
  end

  private

  def pagination_window
    if @params[:direction] == "prev"
      (@params[:cursor_created_at]..)
    else
      (..@params[:cursor_created_at])
    end
  end

  def pagination_url(direction:)
    return "" if @seek == false && direction == @params[:direction]
    return "" if @params[:cursor_id].blank? && direction == "prev"

    cursor = direction == "prev" ? paginated_records.first : paginated_records.last

    uri = URI(@url)
    params = Hash[URI.decode_www_form(uri.query || "")]
             .merge("cursor_created_at" => cursor.created_at, "cursor_id" => cursor.id, "direction" => direction)
    uri.query = URI.encode_www_form(params)
    uri
  end

  def paginated_records
    return @paginated_records if defined? @paginated_records

    @paginated_records = @records
                         .unscope(:order)
                         .where(created_at: pagination_window)
                         .where.not(id: @params[:cursor_id])
                         .order(created_at: order_direction)
                         .limit(@limit + 1)
                         .to_a

    @seek = (@paginated_records.size > @limit)
    @paginated_records.pop if @seek == true
    @paginated_records.reverse! if @params[:direction] == "prev"
    @paginated_records
  end

  def order_direction
    return :asc if @params[:direction] == "prev"

    :desc
  end
end
