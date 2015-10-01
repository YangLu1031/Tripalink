class CarFeature < ActiveRecord::Base
  has_many :car_feature_relations, class_name: 'CarFeatureRelation', foreign_key: 'feature_id', dependent: :destroy
  has_many :cars, through: :car_feature_relations, source: :car
end
