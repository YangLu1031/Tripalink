class UsersController < ApplicationController
  before_action :signed_in, only: :show
  # before_action :admin_user, only: :index
  skip_before_filter :verify_authenticity_token, only: [:signin, :signup]

  def show
    if current_user.admin?
      @user = User.find_by(id: params[:id])
    else
      @user = current_user
    end
  end

  def index
    redirect_to root_path
  end

  def edit
    if current_user.id != params[:id].to_i
      redirect_to root_path
    else
      @user = current_user
    end
  end

  def update
    if current_user.id != params[:id].to_i
      redirect_to root_path
    else
      current_user.name = params[:user][:name]
      current_user.email = params[:user][:email]
      current_user.phone = params[:user][:phone]
      current_user.save
      redirect_to current_user
    end
  end

  def cars
    check_same_user
    @cars = current_user.cars
    render 'show_cars'
  end

  def appointments
    check_same_user
    @appointments = current_user.appointments
    render 'show_appointments'
  end

  def appointment_list
    # check_same_user
    today = params[:today] ? Date.parse(params[:today]) : Date.today
    time_range = today.at_beginning_of_month...today.at_beginning_of_month.next_month
    user = User.find(params[:id])
    @appointments = user.appointments.joins(:time_window)
                        .where("time_windows.date" => time_range)
                        .select("appointments.*, time_windows.date as date, time_windows.hour as hour")

    # unscheduled appointments
    twids = []
    # outer join was used only to make date and hour available in json
    unscheduled = user.appointments.where(time_window_id: nil)
               .joins("LEFT OUTER JOIN time_windows ON appointments.time_window_id = time_windows.id")
               .select("appointments.*, time_windows.date as date, time_windows.hour as hour")
    unscheduled.each { |apt| twids |= apt.time_window_ids }
    time_windows = TimeWindow.where(id: twids).where(date: time_range)  # time windows in this month
    correct_twids = time_windows.map { |tw| tw.id }  # time_window_id that falls in this month
    tw_hash = {}
    time_windows.each do |tw| tw_hash[tw.id] = tw end
    unscheduled_thismonth = unscheduled.select { |apt| (apt.time_window_ids & correct_twids).size != 0 }
    duplicate_tws = []
    unscheduled_thismonth.each do |apt|
      (apt.time_window_ids & correct_twids).each do |twid|
        dup_apt = apt.dup
        dup_apt.id = apt.id  # duplicated ActiveRecord has no id
        dup_apt.date = tw_hash[twid].date
        dup_apt.hour = tw_hash[twid].hour
        duplicate_tws << dup_apt
      end
    end
    render json: @appointments + duplicate_tws
  end

  def sell_transactions
    check_same_user
    @transactions = current_user.sell_transactions
    @cars = current_user.cars
    render 'show_transactions', locals: { type: 0 }
  end

  def buy_transactions
    check_same_user
    user = current_user
    @transactions = user.sell_transactions
    render 'show_transactions', locals: { type: 1 }
  end

  def signin
    if request.post?
      user = authenticate(params[:email], params[:password])
      if not user
        render json: {message: "Signin failed!"}
        return
      end
      sign_in user
      if user_signed_in?
        render json: {message: "Signin success!", email: current_user.email}
      else
        render json: {message: "Signin failed!"}
      end
      return
    end
    render json: {message: "Invalid parameters!"}
  end

  def signup
    if params[:user][:password] != params[:user][:password_confirmation]
      render json: {message: "Passwords must match!"}
      return
    end
    user = User.new(params.require(:user).permit(:name, :email, :phone))
    user.password = params[:user][:password]
    if user.save
      sign_in user
      render json: {message: "Signup success!"}
    else
      render json: {message: "Signup failed!"}
    end
  end

  def authenticate(email, password)
    user = User.find_by(:email => email)
    return nil unless user
    user.valid_password?(password) ? user : nil
  end

  private

  def check_same_user
    if current_user.id != params[:id].to_i
      redirect_to root_path
    end
  end

  def signed_in
    unless user_signed_in?
      redirect_to root_url
    end
  end

  def admin_user
    unless user_signed_in? || current_user.admin?
      redirect_to root_url
    end
  end
end
