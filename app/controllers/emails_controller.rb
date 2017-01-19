class EmailsController < ApplicationController
  def send_email
    email = params[:email]
    image = params[:image]
    ReportMailer.report_email(email, image).deliver_now
  end
end
