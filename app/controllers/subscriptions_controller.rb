class SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:notify_with_api]

  def subscribe
    email = params[:email]
    mailchimp = Mailchimp::API.new(ENV.fetch('MAILCHIMP_API_KEY'))

    begin
      mailchimp.lists.subscribe(ENV.fetch('MAILCHIMP_LIST_ID'),
                                {email: email})
      render json: {message: "Alright, we signed up: #{email} Thank you! We'll be in touch"}, status: 200
    rescue Mailchimp::ListAlreadySubscribedError
      render json: {message: "#{email} is already subscribed to the list"}, status: 400
    rescue Mailchimp::ListDoesNotExistError
      render json: {message: 'The list could not be found'}, status: 400
      return
    rescue Mailchimp::Error => ex
      if ex.message
        render json: {message: ex.message}, status: 400
      else
        render json: {message: 'An unknown error occurred'}, status: 400
      end
    end
  end

  def check_api
    begin
      session[:api_token] = params[:api_token]
      client = Slack::Web::Client.new(token: params[:api_token])
      team = client.team_info
      channels = client.channels_list.channels
      render json: {team_name: team[:team][:name], icon: team[:team][:icon][:image_88], channels: channels.map { |c| c[:name] }}
    rescue => ex
      render json: {message: 'An unknown error occurred'}, status: 400
    end

  end

  def notify_with_api
    SlackNotifier.api_notify(session[:api_token], params[:channel], params[:image_path], 'Visualizer report')
    @message = {message: "Notification sent to ##{params[:channel]}"}
    respond_to do |format|
      format.js
    end
  end

  def notify_with_webhook
    image_path = "#{request.protocol}#{request.host_with_port}#{params[:image_path]}"
    SlackNotifier.notify_hook(params[:hook], image_path, 'Visualizer report ')
    render json: {message: 'Notification sent'}
  end
end
