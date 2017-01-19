class EmailsController < ApplicationController
  def send_email
    email = params[:email]
    ReportMailer.report_email(email).deliver_now
  end
end
