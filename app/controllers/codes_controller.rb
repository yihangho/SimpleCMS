class CodesController < ApplicationController
  before_action :signed_in_users_only

  def save
    @code = current_user.codes.find_by(:problem_id => code_params[:problem_id])
    if @code
      @code.update_attribute(:code, code_params[:code])
    else
      current_user.codes.create(code_params)
    end
    head :no_content
  end

  private

  def code_params
    params.require(:code).permit(:problem_id, :code)
  end
end
