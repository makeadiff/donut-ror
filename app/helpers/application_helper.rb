module ApplicationHelper
  def sortable(column, title = nil)
    title ||= column.titleize
    direction = sort_direction == "asc" ? "desc" : "asc"
    link_to title, params.merge(:sort => column, :direction => direction, :page => nil)
  end
end