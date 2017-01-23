module SlackNotifier

  def self.notify_hook(hook, image_path, message)
    client = Slack::Notifier.new hook
    client.ping 'Google Analytics Visualizer report',
                attachments: [{
                                  image_url: image_path,
                                  initial_comment: message
                              }]
  end

  def self.api_notify(token, channel, file, message)
    client = Slack::Web::Client.new(token: token)
    client.files_upload(
        channels: channel,
        as_user: true,
        file: Faraday::UploadIO.new("public/#{file}", 'image/png'),
        title: 'Report',
        filename: 'report.png',
        initial_comment: message
    )
  end

end