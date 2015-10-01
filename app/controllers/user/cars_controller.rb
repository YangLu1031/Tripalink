class User::CarsController < ApplicationController
  before_action :authenticate_user!

  # GET /user/:id/cars
  def index
    @cars = current_user.cars
    if current_user.id != params[:user_id].to_i
      redirect_to root_path
    end
    return @cars if @cars else []
  end

  # private
  #   def user_params
  #     params.require(:user).permit(:user_id)
  #   end
end
