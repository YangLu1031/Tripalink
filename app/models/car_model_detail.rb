class CarModelDetail < ActiveRecord::Base
  belongs_to  :car_model, inverse_of: :car_model_detail
end
