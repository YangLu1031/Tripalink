class CarPicture < ActiveRecord::Base
  belongs_to :car, inverse_of: :car_pictures
  mount_uploader :picture, CarPictureUploader

  TYPE_LEFT_FRONT = 0
  TYPE_RIGHT_FRONT = 1
  TYPE_FRONT = 2
  TYPE_LEFT_BACK = 3
  TYPE_RIGHT_BACK = 4
  TYPE_BACK = 5
  TYPE_LEFT = 6
  TYPE_RIGHT = 7
  TYPE_LEFT_FRONT_WHEEL = 8
  TYPE_RIGHT_FRONT_WHEEL = 9
  TYPE_LEFT_BACK_WHEEL = 10
  TYPE_RIGHT_BACK_WHEEL = 11
  TYPE_DRIVER_INNER_DOOR = 12
  TYPE_PASSENGER_INNER_DOOR = 13
  TYPE_FRONT_SEATS = 14
  TYPE_BACK_SEATS = 15
  TYPE_PASSENGER_VIEW = 16
  TYPE_DRIVER_VIEW = 17
  TYPE_DASHBOARD = 18
  TYPE_MONITOR_NORMAL = 19
  TYPE_MONITOR_BACK = 20
  TYPE_CARGO = 21
  TYPE_ENGINE_OVERVIEW = 22
  TYPE_ENGINE_DETAIL = 23

  TYPE_STR_MAP = {
      TYPE_LEFT_FRONT => "left front",
      TYPE_RIGHT_FRONT => "right front",
      TYPE_FRONT => "front",
      TYPE_LEFT_BACK => "left back",
      TYPE_RIGHT_BACK => "right back",
      TYPE_BACK => "back",
      TYPE_LEFT => "left",
      TYPE_RIGHT => "right",
      TYPE_LEFT_FRONT_WHEEL => "left front wheel",
      TYPE_RIGHT_FRONT_WHEEL => "right front wheel",
      TYPE_LEFT_BACK_WHEEL => "left back wheel",
      TYPE_RIGHT_BACK_WHEEL => "right back wheel",
      TYPE_DRIVER_INNER_DOOR => "driver inner door",
      TYPE_PASSENGER_INNER_DOOR => "passenger inner door",
      TYPE_FRONT_SEATS => "front seats",
      TYPE_BACK_SEATS => "back seats",
      TYPE_PASSENGER_VIEW => "passenger view",
      TYPE_DRIVER_VIEW => "driver view",
      TYPE_DASHBOARD => "dashboard",
      TYPE_MONITOR_NORMAL => "monitor normal",
      TYPE_MONITOR_BACK => "monitor back",
      TYPE_CARGO => "cargo",
      TYPE_ENGINE_OVERVIEW => "engine overview",
      TYPE_ENGINE_DETAIL => "engine detail",
  }

  def get_car_picture_type_str
    return TYPE_STR_MAP[picture_type]
  end

  def CarPicture.get_car_picture_types()
    return TYPE_STR_MAP.invert
  end
end
