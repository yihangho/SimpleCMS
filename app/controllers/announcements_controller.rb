class AnnouncementsController < ApplicationController
  before_action :admin_only, :only => :create

  def create
    @announcement = Announcement.create(announcement_params)
    @announcement.update_attribute(:sender_id, current_user.id)
    redirect_to @announcement.contest
  end

  private

  def announcement_params
    params.require(:announcement).permit(:title, :message, :contest_id)
  end
end
