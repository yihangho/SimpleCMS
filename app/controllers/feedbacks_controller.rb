class FeedbacksController < ApplicationController
  before_action :admin_only, :only => :index

  def index
    @feedbacks = Feedback.all.order(:created_at => :desc)
  end

  def create
  end
end
