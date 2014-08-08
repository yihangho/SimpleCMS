class TasksController < ApplicationController
  # only authorized (eg: invited users to see this problem ) can download this file
  before_action :authorized_users_only  , only: [:show]

  def show
    input_contents = @task.input
    send_data input_contents , filename: "input-#{@task.id}.txt"
  end

  private
    def authorized_users_only
      @task = Task.find params[:id]
      unless @task.problem.visible_to?(current_user)
        flash[:danger] = "You are not allowed to view this problem."
        redirect_to problems_path
      end
    end
end
