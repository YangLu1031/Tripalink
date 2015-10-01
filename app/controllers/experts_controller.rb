class ExpertsController < ApplicationController
  before_action :authenticate_expert!

  def show
    check_same_expert
    @expert = Expert.find(params[:id])
  end

  def edit
    check_same_expert
    @expert = Expert.find(params[:id])
  end

  def update
    if current_expert.id != params[:id].to_i
      redirect_to '/experts'
    else
      current_expert.update_attributes(expert_update_params)
      redirect_to current_expert
    end
  end

  def appointments
    check_same_expert
    appontments_by_type =
        current_expert.appointments.where(appointment_type: params[:type])
    @appointments = appontments_by_type.paginate(page: params[:page])
    @appointment_type_str = Appointment.apt_type params[:type]

    respond_to do |format|
      format.html
      format.js
    end
  end

  def reports
    check_same_expert
    report_type = params[:type].to_i
    @reports = []
    current_expert.appointments.each do |appt|
      if appt.car.status == report_type
        @reports << appt
      end
    end
    respond_to do |format|
      format.html
      format.js
    end
  end

  def editAvailableTime
    @expert = Expert.find(params[:id])
    generateTimeWindows
  end

  def updateAvailableTime
    check_same_expert
    expert = Expert.find_by(id: params[:id])
    workingtws = TimeWindow.where(expert_id:expert.id)
                     .where.not(status:0)
                     .where(date: Date.today..(Date.today+1.week))

    paramids = params[:time_window_ids].select{ |i| i.to_s != 0 }.map{ |i| i.to_i }
    twids = workingtws.map{ |tw| tw.id }
    # newtws = paramids - twids
    offtws = twids - paramids
    TimeWindow.where(expert_id: expert.id).where(status: TimeWindow.statuses[:notavailable]).where(id: paramids)
        .update_all(status: TimeWindow.statuses[:available])
    TimeWindow.where(expert_id: expert.id).where.not(status: TimeWindow.statuses[:reserved]).where(id: offtws)
        .update_all(status: TimeWindow.statuses[:notavailable])
    redirect_to editAvailableTime_expert_path
  end

  def scheduleAppointments
    check_same_expert
    if request.get?
      @expert = Expert.find(params[:id])
      @working_time_windows = TimeWindow.where(expert_id:@expert.id)
                                  .where.not(status:0)
                                  .where(date: Date.today..(Date.today+1.week))
      twids = @working_time_windows.map{ |t| t.id }
      @appointments = Appointment.where(expert_id:@expert.id).order(:id)
                          .where("time_window_ids && ARRAY[?]", twids)
      @appointment_ids = Hash.new { |h, k| h[k] = [] }
      @appointments.each do |apt|
        apt.time_window_ids.each do |time_window_id|
          @appointment_ids[time_window_id] << apt.id
        end
      end
      generateTimeWindows
      # @working_time_windows.each do |time_window|
      #   time_window.appointment_ids = h.has_key?(time_window.id) ? h[time_window.id] : "";
      # end
    elsif request.post?
      apt = Appointment.find(params[:appointment_id])
      time_window_id = params[:time_window_id].to_i
      if apt.time_window_ids && apt.time_window_ids.include?(time_window_id)
        apt.time_window_id = time_window_id
        apt.time_window_ids = nil
        apt.update(params.permit(:car_address, :car_city, :car_zipcode, :car_state))
        if apt.save
          apt.send_schedule_confirmation
          flash[:success] = "Appointment time scheduled!"
          TimeWindow.where(id: time_window_id).update_all(status: TimeWindow.statuses[:reserved])
        else
          flash[:danger] = "Scheduling appointment time failed!"
        end
      end
      redirect_to scheduleAppointments_expert_path
    end
  end

  def upload_car_images
    @car = Car.find(params[:id])
    @car_pictures = find_or_create_car_pictures(@car)
  end

  private
    def expert_update_params
      params.require(:expert).permit(:name, :email, :phone, :avatar)
    end

    def check_same_expert
      if current_expert.id != params[:id].to_i
        redirect_to '/experts'
      end
    end

    def generateTimeWindows
      time_range = Date.today...(Date.today+1.week)
      @time_windows = TimeWindow.where(date: time_range).order(:hour, :date)
                          .where(expert_id:@expert.id)
    end
end
