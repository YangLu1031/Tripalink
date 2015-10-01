class ChargeMailer < ApplicationMailer
  def charge_success(charge, which)
    @charge = charge
    if which == 1
      mail to: @charge.email, subject: "Payment Success"
    else
      mail to: "tripalink.dev@gmail.com", subject: "Payment Success"
    end
  end
end