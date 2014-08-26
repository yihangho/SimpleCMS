class PreviewController < ApplicationController
  include MarkdownHelper

  def markdown
    render :inline => markdown_to_html(params[:input])
  end
end
