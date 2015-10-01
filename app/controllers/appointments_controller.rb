class AppointmentsController < ApplicationController
  before_action :signed_in, only: [:new, :create]
  before_action :admin_or_current_user, except: [:new, :create, :available_time_windows]

  def new
    @apt = Appointment.new
    @apt.car_id = params[:car_id]
    @apt.expert = @apt.car.expert
    if user_signed_in?
      @apt.name = current_user.name
      @apt.email = current_user.email
      @apt.phone = current_user.phone
      @apt.address = current_user.address
      @apt.city = current_user.city
      @apt.state = current_user.state
      @apt.zipcode = current_user.zipcode
    end
    generateTimeWindows @apt.expert.id
  end

  def create
    @apt = Appointment.new(appointment_params)
    @apt.appointment_type = 1

    if user_signed_in?
      current_user.update(params.require(:appointment).permit(:phone, :address, :city, :state, :zipcode))
      user = current_user
    else
      user = User.new(new_appointment_user_params)
      user.password = Devise.friendly_token[0..20]
      user.save
    end
    @apt.user_id = user.id
    @apt.name = user.name
    @apt.email = user.email
    @apt.phone = user.phone
    @apt.expert = @apt.car.expert
    @apt.time_window_ids = params[:appointment][:time_window_ids].select{|id| id.to_i != 0 }.map{ |id| id.to_i }
    unless @apt.time_window_ids
      @apt.errors.add(:time_window_ids, "Please choose some time window. 0<n<=3")
      generateTimeWindows @apt.expert.id
      render 'new'
      return
    end
    # @apt.expert_id = @apt.car.inspector_id
    if @apt.save
      @apt.send_testdrive_request_confirmation
      # TimeWindow.where(id:@apt.time_window_ids).update_all(status: TimeWindow.statuses[:reserved])
      redirect_to @apt
      #redirect_to current_user || root_url
    else
      @apt.errors.full_messages if !@apt.errors.empty?
      generateTimeWindows @apt.expert.id
      render 'new'
      return
    end
  end

  def available_time_windows
    car_id = params[:car_id]
    car = Car.find(car_id)
    from_date = Date.parse params[:from_date] if params[:from_date]
    to_date = Date.parse params[:to_date] if params[:to_date]
    if from_date != nil and to_date != nil
      time_range = from_date...to_date
    else
      time_range = nil
    end
    generateTimeWindows(car.expert.id, time_range)
    height = 6  # number of time windows per day
    width = @time_windows.size / height  # number of days
    i = 0
    tt = []
    (0...height).each do |h|
      row = []
      (0...width).each do |w|
        row << @time_windows[i].as_json(only: %w(id date hour status))
        i += 1
      end
      tt << row
    end
    render json: tt
  end

  def show
    @apt = Appointment.find(params[:id])
  end

  def edit
    @apt = Appointment.find_by(id: params[:id])
    @apt.name = @apt.user.name
    @apt.email = @apt.user.email
    @apt.phone = @apt.user.phone
    generateTimeWindows @apt.expert.id
  end

  def update
    apt = Appointment.find_by(id: params[:id])
    params[:appointment][:time_window_ids] = params[:appointment][:time_window_ids].select{|id| id.to_i != 0 }.map{ |id| id.to_i }
    if apt.sell?
      # apt.time_window.update(status: 1)
      apt.update(appointment_params)
      # apt.time_window.update(status: 2)
      apt.update(expert_id: apt.time_window.expert_id)  #for sell_request
      apt.send_testdrive_request_confirmation
    elsif apt.testdrive?
      apt.update(appointment_params)
    end
    redirect_to apt.user
  end

  def destroy
    apt = Appointment.find_by(id: params[:id])
    apt.send_cancel_confirmation
    apt.delete
    redirect_to appointments_user_path(apt.user)
  end

  private
  def appointment_params
    params.require(:appointment).permit(:address, :city, :state, :zipcode, :car_id, :time_window_ids => [])
  end

  def new_appointment_user_params
    params.require(:appointment).permit(:name, :email, :phone)
  end

  def signed_in
    if user_signed_in?
      true
    else
      redirect_to new_user_session_path
    end
  end

  def admin_or_current_user
    if user_signed_in?
      if current_user.admin? or Appointment.find_by(id: params[:id]).user == current_user
        true
      else
        redirect_to current_user
      end
    else
      redirect_to root_url
    end
  end

  def parse_time_window_ids
    @apt.time_window_ids = params[:appointment][:time_window_ids].map{ |id| id.to_i }
  end

  def generateTimeWindows(expert_id, time_range = nil)
    time_range = Date.today...(Date.today+1.week) if time_range == nil
    @time_windows = TimeWindow.where(date: time_range).order(:hour, :date)
                        .where(expert_id:expert_id)
  end

end
