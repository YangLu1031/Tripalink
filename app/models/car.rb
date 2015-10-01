class Car < ActiveRecord::Base
  DEFAULT_CHECKLIST = ["v1.0", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "0", "0", "0", "0", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "0", "0", "0", "0", "0", "0", "0", "0", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1", "1"]

  before_create :fill_default_checklist

  belongs_to :car_model, inverse_of: :cars
  has_many :car_pictures, inverse_of: :car, dependent: :destroy
  has_many :appointments
  has_one :car_transaction
  belongs_to :expert, class_name: "Expert", foreign_key: "inspector_id"
  belongs_to :owner, class_name: "User", foreign_key: "owner_id"

  # The color references
  belongs_to :interior_color, :class_name => 'CarColor', :foreign_key => 'interior_color_id'
  belongs_to :exterior_color, :class_name => 'CarColor', :foreign_key => 'exterior_color_id'

  has_many :car_feature_relations, class_name: 'CarFeatureRelation', foreign_key: 'car_id', dependent: :destroy
  has_many :features, through: :car_feature_relations, source: :feature
  accepts_nested_attributes_for :features

  # Status keys
  STATUS_ALL_KEY = 0
  STATUS_PRE_INSPECTED_KEY = 1
  STATUS_INSPECTED_KEY = 2
  STATUS_LISTING_FOR_SALE_KEY = 3
  STATUS_SALE_PENDING_KEY = 4
  STATUS_SOLD_KEY = 5
  STATUS_DELETED_KEY = 6

  # Status value
  STATUS_ALL_VALUE = "all"
  STATUS_PRE_INSPECTED_VALUE = "pre-inspected"
  STATUS_INSPECTED_VALUE = "inspected"
  STATUS_LISTING_FOR_SALE_VALUE = "listing"
  STATUS_SALE_PENDING_VALUE = "sale-pending"
  STATUS_SOLD_VALUE = "sold"
  STATUS_DELETED_VALUE = "deleted"

  # Status map
  STATUS_MAP = {
      STATUS_ALL_KEY => STATUS_ALL_VALUE,
      STATUS_PRE_INSPECTED_KEY => STATUS_PRE_INSPECTED_VALUE,
      STATUS_INSPECTED_KEY => STATUS_INSPECTED_VALUE,
      STATUS_LISTING_FOR_SALE_KEY => STATUS_LISTING_FOR_SALE_VALUE,
      STATUS_SALE_PENDING_KEY => STATUS_SALE_PENDING_VALUE,
      STATUS_SOLD_KEY => STATUS_SOLD_VALUE,
      STATUS_DELETED_KEY => STATUS_DELETED_VALUE
  }

  def Car.car_status(status)
    return STATUS_MAP[status]
  end

  def location
    if city.blank? || state.blank?
      "#{city}#{state}"
    else
      "#{city}, #{state}"
    end
  end

  def mpg
    c, h = car_model.fuelEconomy.match(/(\d*)\/(\d*) mpg/).captures
    "#{c} City / #{h} Hwy"
  end

  def fill_default_checklist
    self.checklist = DEFAULT_CHECKLIST
  end

  def to_s
    "#{owner} #{car_model}"
  end
end
