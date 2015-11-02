module ApplicationHelper

  def render_pagination_bar(base_url, item_count, current_page, page_size)
    page_count = (item_count / page_size).ceil
    locals = { base_url: base_url, page_count: page_count, current_page: current_page }
    render partial: "shared/pagination", locals: locals
  end

end
