class AppointmentMailer < ApplicationMailer
  # include SendGrid

  def testdrive_request(appointment, which)
    # sendgrid_category "Test Drive Request"
    @appointment = appointment
    if which == 1
      mail to: @appointment.user.email, subject: "Test Drive Request Confirmation"
    else
      mail to: @appointment.expert.email, subject: "Test Drive Request Confirmation"
    end
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.appointment_mailer.schedule_appointment.subject
  #
  def schedule_appointment(appointment, which)
    # sendgrid_category "Sell Request"
    @appointment = appointment
    if which == 1
      mail to: @appointment.user.email, subject: "Appointment schedule confirmation"
    else
      email = "tripalink.dev@gmail.com" if !@appointment.expert
      mail to: email, subject: "Appointment schedule confirmation"
    end
  end

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.appointment_mailer.cancel_appointment.subject
  #
  def cancel_appointment(appointment)
    @appointment = appointment
    if which == 1
      mail to: @appointment.user.email, subject: "Appointment cancel confirmation"
    else
      mail to: @appointment.expert.email, subject: "Appointment cancel confirmation"
    end
  end
end
