class Charge < ActiveRecord::Base

  def send_email
    ChargeMailer.charge_success(self, 1).deliver_now
    ChargeMailer.charge_success(self, 2).deliver_now
  end

end
