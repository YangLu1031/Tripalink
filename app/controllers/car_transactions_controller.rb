class CarTransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :signed_in

  def new
    @car_transaction = CarTransaction.new
    autofill_info(@car_transaction, params[:car_id])
    @car_transaction.email = current_user.email
    @car_transaction.phone = current_user.phone

    @car_transaction.billing_address = current_user.address
    @car_transaction.billing_city = current_user.city
    @car_transaction.billing_state = current_user.state
    @car_transaction.billing_zipcode = current_user.zipcode

    @car_transaction.delivery_address = current_user.address
    @car_transaction.delivery_city = current_user.city
    @car_transaction.delivery_state = current_user.state
    @car_transaction.delivery_zipcode = current_user.zipcode

    @car = Car.find(params[:car_id])
  end

  def create
    @car_transaction = CarTransaction.new(car_transaction_params)
    autofill_info(@car_transaction, params[:car_transaction][:car_id])
    if @car_transaction.save
      car = @car_transaction.car
      car.status = Car::STATUS_SALE_PENDING_KEY
      car.save
      redirect_to @car_transaction
    else
      @car_transaction.errors.full_messages if !@car_transaction.errors.empty?
      render 'new'
      return
    end
  end

  def show
    @transaction = CarTransaction.find(params[:id])
    # unless is_allowed @transaction, params
    #   redirect_to new_user_session_path
    # end
  end

  private
  # def is_allowed(transaction, params)
  #   transaction_type = params[:type]
  #   if transaction_type == 0 and current_user.sell_transactions.where(type: transaction_type)
  #     true
  #   elsif transaction_type == 1 and current_user.buy_transactions.where(type: transaction_type)
  #     true
  #   else
  #     false
  #   end
  # end

  def signed_in
    if user_signed_in?
      true
    else
      redirect_to new_user_session_path
    end
  end

  def autofill_info(car_transaction, car_id) #critial info that should be read from database
    unless car_id
      flash[:danger] = "Invalid parameters."
      redirect_to cars_path
      return
    end
    car_transaction.car = Car.find_by(id: car_id)
    if car_transaction.car == nil
      flash[:danger] = "No such car."
      redirect_to cars_path
      return
    end
    car_transaction.buyer_id = current_user.id
    car_transaction.seller_id = car_transaction.car.owner_id

    car_transaction.name = current_user.name
  end

  def car_transaction_params
    params.require(:car_transaction).permit(:car_id, :phone, :email, :account_type, :routing_number, :account_number,
                                            :billing_address, :billing_city, :billing_state, :billing_zipcode,
                                            :delivery_address, :delivery_city, :delivery_state, :delivery_zipcode)
    #buyer_id, seller_id, name, price should be read from database, rather than trust input
  end

end
