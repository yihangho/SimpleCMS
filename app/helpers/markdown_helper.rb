module MarkdownHelper
  def markdown_to_html(md)
    Kramdown::Document.new(md.to_s, :input => "GFM", :coderay_line_numbers => nil).to_html.html_safe
  end
end
