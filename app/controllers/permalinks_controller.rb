class PermalinksController < ApplicationController
  def resolver
    redirect_to Permalink.find_by!(:url => params[:permalink]).linkable, :status => :moved_permanently
  end
end
