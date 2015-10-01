class TimeWindow < ActiveRecord::Base
  has_many :appointments
  enum status: { notavailable: 0, available: 1, reserved: 2}

  def to_s
    "#{date} #{hour}"
  end
end
