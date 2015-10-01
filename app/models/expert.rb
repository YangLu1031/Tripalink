class Expert < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  #geokit-rails requirement
  acts_as_mappable

  has_many :appointments
  has_many :sell_requests

  mount_uploader :avatar, AvatarUploader
end
