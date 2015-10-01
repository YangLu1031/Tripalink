class Api::V1::ExpertapiController < ApplicationController
  before_action :account_authentication!, only: [:get_token]
  before_action :token_valid?, only: [:get_expert_info, :get_appointments, :get_user_info, :get_time_window]
  respond_to :json

  def get_token
    respond_with(:jwt => AuthToken.issue_token({:email => params[:email]}))
  end

  #/?email=***
  def get_expert_info
    respond_with Expert.find_by(:email=> params[:email]).to_json(:only => [:email, :name, :avatar])
  end


  #/?email=***
  def get_appointments
    respond_with Expert.find_by(:email=> params[:email]).appointments.to_json(:only => [:id, :appointment_type, :address, 
        :city, :state, :zipcode, :user_id, :time_window_id, :car_id])
  end

  #/?appointment_id=***
  def get_user_info
    respond_with Appointment.find(params[:appointment_id]).user.to_json(:only => [:name, :phone, :avatar])
  end

  #/?time_window_id=***
  def get_time_window
    respond_with TimeWindow.find(params[:time_window_id]).to_json(:only => [:date, :hour])
  end

  private

  def account_authentication!
    if !(Expert.find_by(:email=>params[:email]) && Expert.find_by(:email=>params[:email]).valid_password?(params[:password]))
      render :json => {:error => "unauthorized!"}, status: :unauthorized
    end
  end

  def token_valid?
    @payload, @valid = AuthToken.valid?(request.headers["jwt"])
    if !@valid
      render :json => {:error => "authorization failed"}, status: :unauthorized
    end
  end
end
