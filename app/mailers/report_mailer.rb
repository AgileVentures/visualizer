class ReportMailer < ApplicationMailer
  default from: 'info@craftacademy.se'

  def report_email(email, image)
    @image = image
    attachments["visualizer_report_generated_#{Date.today}.png"] = File.read('app/assets/images/fake_image.jpg')
    mail(to: email, subject: 'This is a report email')
  end
end
