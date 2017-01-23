class PagesController < ApplicationController
  include SlackNotifier

  API_URL = 'https://accounts.google.com/o/oauth2'

  before_action :get_service, only: [:analytics, :get_data]

  def index
  end

  def redirect
    client = Signet::OAuth2::Client.new({client_id: ENV.fetch('GOOGLE_API_CLIENT_ID'),
                                         client_secret: ENV.fetch('GOOGLE_API_CLIENT_SECRET'),
                                         authorization_uri: "#{API_URL}/auth",
                                         scope: Google::Apis::AnalyticsV3::AUTH_ANALYTICS_READONLY,
                                         redirect_uri: url_for(action: :callback)
                                        })
    redirect_to client.authorization_uri.to_s
  end

  def callback
    client = Signet::OAuth2::Client.new({client_id: ENV.fetch('GOOGLE_API_CLIENT_ID'),
                                         client_secret: ENV.fetch('GOOGLE_API_CLIENT_SECRET'),
                                         token_credential_uri: "#{API_URL}/token",
                                         redirect_uri: url_for(action: :callback),
                                         code: params[:code]
                                        })
    response = client.fetch_access_token!
    session[:access_token] = response['access_token']
    redirect_to url_for(action: :analytics)
  end

  def analytics
    begin
      @account_summaries = @service.list_account_summaries
      session[:user_name] = @account_summaries.username
    rescue Google::Apis::AuthorizationError => ex
      if ex.message
        render json: {message: ex}
      end
    end
  end

  def get_data
    begin
      asset = AnalyticsPeriod.new(@service, params)
      @property = asset.property
      @image = ReportGenerator.generate(asset)
      render :analytics
    rescue Google::Apis::AuthorizationError => ex
      if ex.message
        render json: {message: ex}
      end
    end
  end

  private
  def get_service
    @service = Google::Apis::AnalyticsV3::AnalyticsService.new
    @service.authorization = session[:access_token]
  end
end
