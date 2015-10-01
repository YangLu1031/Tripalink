class Appointment < ActiveRecord::Base
  attr_accessor :name, :email, :phone
  # attr_accessor :date, :hour
  belongs_to :expert
  belongs_to :user
  belongs_to :time_window
  belongs_to :sell_request
  belongs_to :car

  validates_presence_of :address
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :zipcode
  # validates_presence_of :time_window_id
  # validate :validate_time_window, on: :create
  # validates_presence_of :time_window_ids

  # Constants for different appointment types
  TYPE_SELL = 0
  TYPE_TEST_DRIVE = 1
  TYPE_DELIVERY = 2

  def apt_type
    if appointment_type == TYPE_SELL
      "Sell"
    elsif appointment_type == TYPE_TEST_DRIVE
      "Test Drive"
    elsif appointment_type == TYPE_DELIVERY
      "Delivery"
    end
  end

  def Appointment.apt_type(type_id_str)
    type_id = type_id_str.to_i
    if type_id == TYPE_SELL
      "Inspection"
    elsif type_id == TYPE_TEST_DRIVE
      "Test Drive"
    elsif type_id == TYPE_DELIVERY
      "Delivery"
    end
  end

  def send_testdrive_request_confirmation
    AppointmentMailer.testdrive_request(self, 1).deliver_now
    AppointmentMailer.testdrive_request(self, 2).deliver_now
  end

  def send_schedule_confirmation
    AppointmentMailer.schedule_appointment(self, 1).deliver_now
    AppointmentMailer.schedule_appointment(self, 2).deliver_now
  end

  def send_cancel_confirmation
    AppointmentMailer.cancel_appointment(self, 1).deliver_now
    AppointmentMailer.cancel_appointment(self, 2).deliver_now
  end

  private

  def validate_time_window
    if time_window_ids
      time_window_ids.compact!
      if time_window_ids.size == 0
        errors.add(:time_window_ids, "Please choose a time window. Choose three at most.")
      end
    end
  end

end
