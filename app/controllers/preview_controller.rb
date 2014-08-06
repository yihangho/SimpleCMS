class PreviewController < ApplicationController
  def markdown
    render :inline => Kramdown::Document.new(params[:input]).to_html
  end
end
