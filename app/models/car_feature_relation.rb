class CarFeatureRelation < ActiveRecord::Base
  belongs_to :car, :class_name => 'Car', :foreign_key => 'car_id'
  belongs_to :feature, :class_name => 'CarFeature', :foreign_key => 'feature_id'
  validates :car_id, presence: true
  validates :feature_id, presence: true
end
