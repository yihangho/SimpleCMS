module ApplicationHelper
  def format_datetime(datetime, zone)
    if zone
      datetime.in_time_zone(zone).strftime("%b %-d, %Y %l:%M %p %z")
    else
      datetime.strftime("%b %-d, %Y %l:%M %p %z")
    end
  end

  def controller_stylesheet_link_tag
    stylesheet = controller.controller_name
    stylesheet_link_tag stylesheet
  end
end
