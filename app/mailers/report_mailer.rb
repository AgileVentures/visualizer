class ReportMailer < ApplicationMailer
  default from: 'info@craftacademy.se'

  def report_email(email, image)
    attachments["visualizer_report_generated_#{Date.today}.png"] = File.read('app/assets/images/fake_image.jpg') # put the real image here instead of the unicorn. Passing the image hot-potato across all these methods does *not* mean I can print it out in the email.
    mail(to: email, subject: 'This is a report email')
  end
end
