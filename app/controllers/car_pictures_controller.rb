class CarPicturesController < ApplicationController

  def index
    @car = Car.find(params[:car_id])
    @car_pictures = @car.car_pictures
    @car_picture_types = CarPicture.get_car_picture_types
  end

  def create
    car_picture_params = get_car_picture_params
    # Sanity check the necessary fields
    if has_required_fields? car_picture_params
      @car = Car.find(params[:car_id])
      @car_picture = @car.car_pictures.create(car_picture_params)
      redirect_to car_car_pictures_path(@car)
    else
      redirect_to car_car_pictures_path(params[:car_id])
    end
  end

  def destroy
    @car = Car.find(params[:car_id])
    @car.car_pictures.destroy(params[:id])
    redirect_to car_car_pictures_path(@car)
  end

  private
    def get_car_picture_params
      params.require(:car_picture).permit(:picture, :picture_type, :description)
    end

    def has_required_fields?(car_picture_params)
      car_picture_params.has_key?(:picture) and
      car_picture_params.has_key?(:picture_type)
    end
end
