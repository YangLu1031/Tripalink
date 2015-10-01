class SellRequestsController < ApplicationController

  def new_user
    # @sell_request = SellRequest.new session[:sell_params]
    # @sell_request.current_step = 3
    # session[:sell_params].deep_merge!(params[:sell_request]) if params[:sell_request]
    # session[:sell_step] = 3;
    #get post params and create a new user
    user = User.new new_user_params
    # user.password = Devise.friendly_token[0..20]
    user.save
    sign_in user
    # if user_signed_in?
    #   @sell_request.name = current_user.name
    #   @sell_request.email = current_user.email
    #   @sell_request.phone = current_user.phone
    # end
  end


  def create_appointment
    sell_request = SellRequest.new params.permit(:mileage, :vin, :outstanding_price, :clean_price, :average_price, :trade_in_rough_price, :car_model_id)
    sell_request.save
    appointment = Appointment.new
    appointment.sell_request_id = sell_request.id
    appointment.user_id = current_user.id
    appointment.appointment_type = 0
    appointment.address = params[:address]
    appointment.city = params[:city]
    appointment.state = params[:state]
    appointment.zipcode = params[:zipcode]
    current_user.update(params.permit(:name, :phone))
    appointment.time_window_ids = params[:time_window_ids].select{|id| id.to_i != 0 }.map{ |id| id.to_i }
    available_experts = getAvailableExperts(params.permit(:lat, :lng).map{ |k, v| v.to_f })
    tw = getRandomTimeWindow(available_experts, appointment.time_window_ids)
    if tw
      tw.update(status: 2)
      appointment.expert_id = tw.expert_id
      appointment.time_window_id = tw.id
    end
    appointment.save
    appointment.send_schedule_confirmation
    render :json => {:status => true}
  end

  #
  # def create
  #   session[:sell_params] ||= {}
  #   session[:sell_params].deep_merge!(params[:sell_request]) if params[:sell_request]
  #   @sell_request = SellRequest.new session[:sell_params]
  #   @sell_request.current_step = session[:sell_step]
  #   if params[:back_button]
  #     @sell_request.previous_step if !@sell_request.first_step?
  #   else
  #     if !@sell_request.last_step?
  #       @sell_request.next_step
  #     else
  #       # At last step and not :back_button, that is, submitting at the last step. So, create a record.
  #       user = User.find_by(email: session[:sell_params]["email"])
  #       if user.nil?
  #         user = User.new(new_user_params)
  #         user.password = Devise.friendly_token[0..20]
  #         user.save
  #       else
  #         user.update(new_user_params)
  #       end
  #
  #       @sell_request.user_id = user.id
  #       @sell_request.save
  #
  #       session[:sell_params]["time_window_ids"] = session[:sell_params]["time_window_ids"].select{|id| id.to_i != 0 }.map{ |id| id.to_i }
  #       appointment = Appointment.new(session[:sell_params].slice("address", "city", "state", "zipcode", "time_window_ids"))
  #       appointment.user_id = user.id
  #       appointment.appointment_type = :sell
  #       appointment.sell_request_id = @sell_request.id
  #       available_experts = getAvailableExperts(session[:sell_params].slice("lat", "lng").map{ |k, v| v.to_f })
  #       # tw = TimeWindow.find_by(id: session[:sell_params]["time_window_id"])
  #       tw = getRandomTimeWindow(available_experts,
  #                                session[:sell_params]["time_window_ids"]
  #                                    .select{ |i| i.to_i != 0 }.map{ |i| i.to_i })
  #       if tw
  #         tw.update(status: 2)
  #         appointment.expert_id = tw.expert_id
  #         appointment.time_window_id = tw.id
  #       end
  #       appointment.save
  #     end
  #     if @sell_request.current_step == 3
  #       @sell_request.privateprice, @sell_request.tradeinprice = get_price('clean')
  #       # @sell_request.clean = get_titleinfo(1)
  #       # get_vininfo
  #     elsif @sell_request.current_step == 4
  #       if user_signed_in?
  #         @sell_request.name = current_user.name
  #         @sell_request.email = current_user.email
  #         @sell_request.phone = current_user.phone
  #         @sell_request.address = current_user.address
  #         @sell_request.city = current_user.city
  #         @sell_request.state = current_user.state
  #       end
  #     elsif @sell_request.current_step == 5
  #       if user_signed_in?
  #         current_user.update(params.require(:sell_request).permit(:address, :city, :state))
  #       end
  #       generateTimeWindows(params.require(:sell_request).permit(:lat, :lng).map{ |k, v| v.to_f })
  #     end
  #   end
  #   session[:sell_step] = @sell_request.current_step
  #   if @sell_request.new_record?
  #     render 'new'
  #   else
  #     flash[:notice] = "Sell Request submitted."
  #     session[:sell_step] = session[:sell_params] = nil
  #     redirect_to @sell_request
  #   end
  #   #TODO 页面跳转还是很混乱, 需要修改
  # end

  def available_time_windows
    from_date = Date.parse params[:from_date] if params[:from_date]
    to_date = Date.parse params[:to_date] if params[:to_date]
    if from_date != nil and to_date != nil
      time_range = from_date...to_date
    else
      time_range = nil
    end
    generateTimeWindows([params[:lat].to_f, params[:lng].to_f], time_range)
    # @time_windows.to_json
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

  # def show
  #   @sell_request = SellRequest.find_by(id: params[:id])
  # end


  def get_all_price
    url_outstanding = "https://api.edmunds.com/v1/api/tmv/tmvservice/calculateusedtmv?styleid=" + params[:style_id] + "&condition=outstanding" + "&mileage=" +
        params[:mileage]+ "&zip=" + params[:zipcode] + "&fmt=json&api_key=" +Rails.application.secrets.edmunds_key;
    url_clean = "https://api.edmunds.com/v1/api/tmv/tmvservice/calculateusedtmv?styleid=" + params[:style_id] + "&condition=clean" + "&mileage=" +
        params[:mileage]+ "&zip=" + params[:zipcode] + "&fmt=json&api_key=" +Rails.application.secrets.edmunds_key;
    url_average = "https://api.edmunds.com/v1/api/tmv/tmvservice/calculateusedtmv?styleid=" + params[:style_id] + "&condition=average" + "&mileage=" +
        params[:mileage]+ "&zip=" + params[:zipcode] + "&fmt=json&api_key=" +Rails.application.secrets.edmunds_key;
    url_rough = "https://api.edmunds.com/v1/api/tmv/tmvservice/calculateusedtmv?styleid=" + params[:style_id] + "&condition=rough" + "&mileage=" +
        params[:mileage]+ "&zip=" + params[:zipcode] + "&fmt=json&api_key=" +Rails.application.secrets.edmunds_key;
    json_outstanding = JSON.parse(OpenURI.open_uri(url_outstanding).read)
    json_clean = JSON.parse(OpenURI.open_uri(url_clean).read)
    json_average = JSON.parse(OpenURI.open_uri(url_average).read)
    json_rough = JSON.parse(OpenURI.open_uri(url_rough).read)
    price_outstanding = json_outstanding['tmv']
    price_clean = json_clean['tmv']
    price_average = json_average['tmv']
    price_rough = json_rough['tmv']
    if price_outstanding['nationalBasePrice']['usedPrivateParty'].nil? ||
        price_clean['nationalBasePrice']['usedPrivateParty'].nil? ||
        price_average['nationalBasePrice']['usedTradeIn'].nil? ||
        price_rough['nationalBasePrice']['usedTradeIn'].nil?
      render :json => {}
    else
      private_outstanding_price = price_outstanding['nationalBasePrice']['usedPrivateParty'] + price_outstanding['regionalAdjustment']['usedPrivateParty'] + price_outstanding['mileageAdjustment']['usedPrivateParty'] + price_outstanding['conditionAdjustment']['usedPrivateParty']
      private_clean_price = price_clean['nationalBasePrice']['usedPrivateParty'] + price_clean['regionalAdjustment']['usedPrivateParty'] + price_clean['mileageAdjustment']['usedPrivateParty'] + price_clean['conditionAdjustment']['usedPrivateParty']
      trade_in_average_price = price_average['nationalBasePrice']['usedTradeIn'] + price_average['regionalAdjustment']['usedTradeIn'] + price_average['mileageAdjustment']['usedTradeIn'] + price_average['conditionAdjustment']['usedTradeIn']
      trade_in_rough_price = price_rough['nationalBasePrice']['usedTradeIn'] + price_rough['regionalAdjustment']['usedTradeIn'] + price_rough['mileageAdjustment']['usedTradeIn'] + price_rough['conditionAdjustment']['usedTradeIn']
      render :json => {:outstanding_price => private_outstanding_price, :clean_price => private_clean_price, :average_price => trade_in_average_price,
                       :rough_price => trade_in_rough_price}
    end
  end


  def get_vininfo
    url = "https://api.edmunds.com/api/vehicle/v2/vins/" + params[:vin] + "?fmt=json&api_key=" + Rails.application.secrets.edmunds_key
    flag = false
    begin
      json = JSON.parse(OpenURI.open_uri(url).read)
      #TODO still need to handle error json respond
      for i in json['years']
        for j in i['styles']
          if params[:style_id].to_s == j['id'].to_s
            flag = true
            break
          end
        end
      end
      render :json => {:result => flag}
    rescue
      render :json => {:result => false}
    end
  end


  private

  #mode = 1, test mode
  #mode = 0, normal mode
  def get_titleinfo(mode)
    if mode
      url = "https://api.vinaudit.com/pullreport.php?user=" + Rails.application.secrets.vin_audit_username + "&pass=" + Rails.application.secrets.vin_audit_password +
          "&vin=" + @sell_request.vin + "&key=" + Rails.application.secrets.vin_audit_key + "&format=json" + "&mode=test" + "&id=" + rand(10**12).to_s
    else
       url = "https://api.vinaudit.com/pullreport.php?user=" + Rails.application.secrets.vin_audit_username + "&pass=" + Rails.application.secrets.vin_audit_password +
          "&vin=" + @sell_request.vin + "&key=" + Rails.application.secrets.vin_audit_key + "&format=json" +"&id=" + rand(10**12).to_s
    end

    clean = nil
    # try_times = 6 #do it for at most 6 times
    # TODO may need to discuss the times
    while clean == nil
      json = JSON.parse(OpenURI.open_uri(url, {ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE}).read)
      clean = json['clean']
      # try_times -= 1
      # if try_times == 0
      #   break;
      # end
    end
    clean
    # if
  end

  def getRandomTimeWindow(experts, time_window_ids)
    return nil unless experts && experts.size != 0 && time_window_ids && time_window_ids.size != 0
    time_windows = TimeWindow.find(time_window_ids)
    time_windows.each do |time_window|
      return time_window if time_window.available?
    end
    time_windows.each do |time_window|
      TimeWindow.where(date: time_window.date, hour: time_window.hour)
          .where(expert_id: experts.map{ |e| e.id}).where.not(id: time_window.id) do |tw|
        return tw if tw.available?
      end
    end
    return nil
  end

  def getAvailableExperts(latlng)
    Expert.where.not(lat: nil).where.not(lng: nil)
        .within(25, :origin => latlng)  #[34.0220715, -118.293995]
        # .where("3 > (SELECT COUNT(*) FROM cars WHERE experts.id=cars.inspector_id) \
        #                                 + (SELECT COUNT(*) FROM appointments \
        #                                   WHERE appointments.appointment_type=0 AND experts.id=appointments.expert_id)")
    ## We don't have so many AGs currently, so just return everybody within 25 miles
  end

  def generateTimeWindows(latlng = nil, time_range = nil)
    available_experts = []
    if latlng != nil && latlng.size == 2
      available_experts = getAvailableExperts(latlng)
    end
    @available_experts = available_experts
    time_range = (Date.today)...(Date.today + 1.week) if time_range == nil
    if available_experts.size != 0
      time_windows = TimeWindow.where(date: time_range).order(:hour, :date)
                         .where(expert_id:available_experts)
      randomExpertId = available_experts.sample.id
      @time_windows = time_windows.select{ |tw| tw.expert_id == randomExpertId }
      tw_availability = {}
      time_windows.each do |time_window|
        key = time_window.date.to_s + "@" + time_window.hour.to_s
        tw_availability[key] = TimeWindow.statuses[:available] if time_window.available?
      end
      @time_windows.each do |time_window|
        key = time_window.date.to_s + "@" + time_window.hour.to_s
        time_window.status = :available if tw_availability[key] == TimeWindow.statuses[:available]
      end
    else
      randomExpertId = Expert.order("RANDOM()").first
      time_windows = TimeWindow.where(date: time_range).order(:hour, :date)
                         .where(expert_id: randomExpertId)
      @time_windows = time_windows.select{ |tw| tw.expert_id == randomExpertId }
      @time_windows.each do |time_window|
        time_window.status = :available
      end
    end
  end

  def new_user_params
    {
      name:          session[:sell_params]["name"],
      phone:         session[:sell_params]["phone"],
      email:         session[:sell_params]["email"],
    }
  end

  def new_appointment_params
    {
      address:         session[:sell_params]["address"],
      city:            session[:sell_params]["city"],
      state:           session[:sell_params]["state"],
      zipcode:         session[:sell_params]["zipcode"],
      time_window_ids: session[:sell_params]["time_window_ids"]
    }
  end

end