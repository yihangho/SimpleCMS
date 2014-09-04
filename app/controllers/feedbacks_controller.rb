class FeedbacksController < ApplicationController
  before_action :admin_only, :only => :index

  def index
    @feedbacks = Feedback.all.order(:created_at => :desc)
  end

  def create
    feedback = Feedback.create(feedback_params)
    render :json => feedback
    Notifier::PushBullet.notify("New feedback for SimpleCMS!", "SimpleCMS", feedbacks_url)
  end

  private

  def feedback_params
    params.require(:feedback).permit(:email, :message)
  end
end
