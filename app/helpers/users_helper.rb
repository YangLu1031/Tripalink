module UsersHelper
  def car_status_str(status)
    Car.car_status status
  end

  def appointment_type_str(appointment)
    if appointment.appointment_type == 0
      "sell"
    else
      "test-drive"
    end
  end

  def sell_transaction_status_str(status)
    if status == 0 or status == 1
      # Both sale-pending and processing-payment accounts for sale-pending for seller
      "sale-pending"
    else
      # Both delivering and delivered accounts for sold for seller
      "sold"
    end
  end

  def buy_transaction_status_str(status)
    if status == 0
      "processing-payment"
    elsif status == 1
      "sale-pending"
    elsif status == 2
      "delivering"
    else
      "delivered"
    end
  end
end
