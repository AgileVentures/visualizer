class ReportMailer < ApplicationMailer
  default from: 'info@craftacademy.se'

  def report_email(email)
    mail(to: email, subject: 'This is a report email')
  end
end
