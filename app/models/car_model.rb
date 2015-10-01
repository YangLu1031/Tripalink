class CarModel < ActiveRecord::Base
  has_one :car_model_detail, inverse_of: :car_model
  has_many :cars, inverse_of: :car_model
  has_many :sell_request

  def to_s
    "#{make} #{model} #{trim} #{year}"
  end
end
