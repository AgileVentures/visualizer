class AnalyticsPeriod

  DEFAULT_START_DATE = 8.days.ago.strftime('%F')
  DEFAULT_END_DATE = 1.day.ago.strftime('%F')


  attr_reader :basic_stats,
              :sources,
              :os_sources,
              :traffic_sources,
              :country_sources,
              :property,
              :previous_period,
              :current_period


  def initialize(service, params)
    @property = get_property(service, params)
    @basic_stats = get_basic_stats(service, params)
    @sources = get_sources(service, params)
    @os_sources = get_os_sources(service, params)
    @traffic_sources = get_traffic_sources(service, params)
    @country_sources = get_country_sources(service, params)
    @previous_period, @current_period = get_periods(@basic_stats)
  end


  def change_in_percent
    "#{change}%"
  end

  def change_status
    change.positive? ? 'increase' : 'decrease'
  end

  def current_visits
    summarize_visits(@current_period)
  end

  def previous_visits
    summarize_visits(@previous_period)
  end

  def current_page_views
    summarize_page_views(@current_period)
  end

  def previous_page_views
    summarize_page_views(@previous_period)
  end

  def current_start_date
    set_date(@current_period[0][0])
  end

  def current_end_date
    set_date(current_period[-1][0])
  end

  private

  def summarize_visits(period)
    period.inject(0) { |sum, e| sum + e[1].to_i }
  end

  def summarize_page_views(period)
    period.inject(0) { |sum, e| sum + e[2].to_i }
  end

  def change
    (((current_visits.to_f / previous_visits) - 1)*100).round(1)
  end

  def get_periods(period)
    period.rows.each_slice(basic_stats.rows.size/2).to_a
  end

  protected

  def set_date(index)
    Date.parse(index)
  end


  def get_property(service, params)
    service.get_web_property(params[:account_id],
                             params[:web_property_id])
  end

  def get_basic_stats(service, params)
    profile_id = "ga:#{params[:profile_id]}"
    start_date = (Date.parse(DEFAULT_START_DATE) - 6.days).strftime('%F')
    end_date = DEFAULT_END_DATE
    metrics = 'ga:sessions, ga:uniquePageviews'
    data = service.get_ga_data(profile_id, start_date, end_date, metrics, {
        dimensions: 'ga:date'
    })
    return data
  end

  def get_sources(service, params)
    profile_id = "ga:#{params[:profile_id]}"
    start_date = DEFAULT_START_DATE
    end_date = DEFAULT_END_DATE
    metrics = 'ga:sessions'
    data = service.get_ga_data(profile_id, start_date, end_date, metrics, {
        dimensions: 'ga:userType'
    })
    return data
  end

  def get_os_sources(service, params)
    profile_id = "ga:#{params[:profile_id]}"
    start_date = DEFAULT_START_DATE
    end_date = DEFAULT_END_DATE
    metrics = 'ga:sessions'
    data = service.get_ga_data(profile_id, start_date, end_date, metrics, {
        dimensions: 'ga:operatingSystem'
    })
    return data.rows.sort! { |a, b| a[1].to_i <=> b[1].to_i }.reverse
  end

  def get_traffic_sources(service, params)
    profile_id = "ga:#{params[:profile_id]}"
    start_date = DEFAULT_START_DATE
    end_date = DEFAULT_END_DATE
    metrics = 'ga:pageviews'
    data = service.get_ga_data(profile_id, start_date, end_date, metrics, {
        dimensions: 'ga:source',
        filters: 'ga:medium==referral',
        sort: '-ga:pageviews'
    })
    return data
  end

  def get_country_sources(service, params)
    profile_id = "ga:#{params[:profile_id]}"
    start_date = DEFAULT_START_DATE
    end_date = DEFAULT_END_DATE
    metrics = 'ga:sessions'
    data = service.get_ga_data(profile_id, start_date, end_date, metrics, {
        dimensions: 'ga:country',
        filters: 'ga:medium==referral',
        sort: '-ga:sessions'
    })
    return data
  end

end