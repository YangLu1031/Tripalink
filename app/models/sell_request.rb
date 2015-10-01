class SellRequest < ActiveRecord::Base
  # attr_accessor :model_trim, :style_id, :privateprice, :tradeinprice, :clean
  # attr_accessor :name, :email, :phone, :zipcode, :time_window_id, :city, :state, :address
  # attr_accessor :addresspicker, :lat, :lng
  # attr_accessor :vin

  # attr_accessor :ABS_4_wheel, :keyless_entry, :navigation_system, :bluetooth_wireless, :parking_sensors, :backup_camera, :heated_seats, :leather, :panorama_roof, :sunroof, :moonroof, :usb, :premium_wheels_19_plus, :premium_wheels, :premium_sound, :steering_wheel_controls, :premium_lights, :head_up_display, :seat_memory

  belongs_to :user
  belongs_to :expert
  has_one :appointment
  belongs_to :car_model

  attr_accessor :time_window_ids

  # validates_presence_of :year,       if: lambda { |o| o.current_step == 1 }
  # validates_presence_of :make,       if: lambda { |o| o.current_step == 1 }
  # validates_presence_of :model,      if: lambda { |o| o.current_step == 1 }
  # validates_presence_of :body_style, if: lambda { |o| o.current_step == 1 }
  # validates_presence_of :trim,       if: lambda { |o| o.current_step == 1 }
  # validates_presence_of :mileage,    if: lambda { |o| o.current_step == 1 }

  # validates_presence_of :drivetrain,    if: lambda { |o| o.current_step == 2 }
  # validates_presence_of :transmission,  if: lambda { |o| o.current_step == 2 }
  # validates_presence_of :license_plate, if: lambda { |o| o.current_step == 2 }
  # validates_presence_of :plate_state,   if: lambda { |o| o.current_step == 2 }

  # validates :zipcode, presence: true, length: { is: 5 }, if: lambda { |o| o.current_step == 2 }
  # validate :valid_zipcode, if: lambda { |o| o.current_step == 2 }
  #
  # validates_presence_of :name,           if: lambda { |o| o.current_step == 4 }
  # validates_presence_of :email,          if: lambda { |o| o.current_step == 4 }
  # validates_presence_of :phone,          if: lambda { |o| o.current_step == 4 }
  # validates_presence_of :address,        if: lambda { |o| o.current_step == 4 }
  # validates_presence_of :time_window_id, if: lambda { |o| o.current_step == 4 }

end
