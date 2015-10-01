class CarTransaction < ActiveRecord::Base
  belongs_to :buyer, class_name: 'User', foreign_key: 'buyer_id'
  belongs_to :seller, class_name: 'User', foreign_key: 'seller_id'
  belongs_to :car, class_name: 'Car', foreign_key: 'car_id'
  belongs_to :expert, class_name: 'Expert', foreign_key: 'expert_id'

  validates_presence_of :email
  validates_presence_of :phone

  validates_presence_of :account_type
  validates_presence_of :routing_number
  validates_presence_of :account_number

  validates_presence_of :billing_address
  validates_presence_of :billing_city
  validates_presence_of :billing_state
  validates_presence_of :billing_zipcode
end
