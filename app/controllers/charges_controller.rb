class ChargesController < ApplicationController
  require 'Stripe'
  def charge
    Stripe.api_key = Rails.application.secrets.stripe_sc_test_key
    token = params[:stripeToken]
    begin
      charge = Stripe::Charge.create(
                                 :amount => 50000,
                                 :currency => "usd",
                                 :source => token,
                                 :description => 'email: ' + params[:email].to_s + ' phone: ' + params[:phone].to_s
      )

      #save charge info to database
      c = Charge.new
      c.carid = params[:carid].to_i
      c.userid = current_user.id
      c.email = params[:email]
      c.phone = params[:phone]
      c.save

      #change this car to sell_pending
      car = Car.find(params[:carid])
      car.status = 4
      car.save
      #send email to both side
      c.send_email

      render :json => {:status => true}
    rescue Stripe::CardError => e
      render :json => {:status => false}
    end
  end

end
