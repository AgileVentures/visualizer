module ReportGenerator
  require 'RMagick'

  include Magick

  DEFAULT_CHART_COLORS = {colors: ['#8DCDC1', '#EB6E44'],
                          marker_color: '#7C786A',
                          font_color: '#7C786A',
                          background_colors: 'transparent'}

  DEFAULT_START_DATE = 8.days.ago.strftime('%F')
  DEFAULT_END_DATE = 1.day.ago.strftime('%F')

  def self.generate(asset)
    file_name = "#{asset.property.name.downcase.gsub(' ', '_')}_week_#{Date.today.strftime('%U')}.png"
    generate_line_graph(asset.basic_stats.rows.last(7), file_name)
    generate_pie_chart(asset.sources, file_name)
    generate_net_chart(asset.os_sources, file_name)
    generate_referers_graph(asset.traffic_sources, file_name)
    generate_countries_graph(asset.country_sources, file_name)
    construct_report(asset, file_name)
  end

  def self.construct_report(asset, file)
      traffic_stats = asset.basic_stats
    report = Image.new(550, 820) do
      self.background_color = '#FFF5C3'
      self.interlace = PNGInterlace
    end

    chart = Image.read(File.join('public', 'tmp', "line_#{file}")).first
    pie = Image.read(File.join('public', 'tmp', "pie_#{file}")).first
    spider = Image.read(File.join('public', 'tmp', "spider_#{file}")).first
    referrers = Image.read(File.join('public', 'tmp', "referrers_#{file}")).first
    countries = Image.read(File.join('public', 'tmp', "countries_#{file}")).first
    platforms = Image.read(File.join('app', 'assets', 'images', 'platforms.png')).first.resize_to_fit!(200)
    logo = Image.read(File.join('app', 'assets', 'images', 'basic-logo-450X450.png')).first.resize_to_fit!(100)


    header = Image.new(550, 70) do
      self.background_color = '#8DCDC1'
    end

    title_text = Draw.new
    title_text.annotate(header, 0, 0, 20, 15, "Weekly Insights for #{asset.property.name}") do
      title_text.gravity = NorthWestGravity
      self.pointsize = 20
      self.font = "#{Rails.root}/app/assets/fonts/Quicksand-Bold.ttf"
      self.fill = '#FFF5C3'
      self.font_weight = BoldWeight
    end

    if asset.property.website_url.length < 25
      sub_title_text = Draw.new
      sub_title_text.annotate(header, 0, 0, 20, 45, "Website URL: #{asset.property.website_url}") do
        sub_title_text.gravity = NorthEastGravity
        self.font = "#{Rails.root}/app/assets/fonts/Quicksand-Bold.ttf"
        self.pointsize = 13
        self.fill = '#EB6E44'
        self.font_weight = BoldWeight
      end
    end


    date_text = Draw.new
    date_text.annotate(header, 0, 0, 20, 45, "Week of  #{asset.current_start_date.strftime('%B %d')} - #{asset.current_end_date.strftime('%B %d')}") do
      date_text.gravity = NorthWestGravity
      self.font = "#{Rails.root}/app/assets/fonts/Quicksand-Bold.ttf"
      self.pointsize = 13
      self.fill = '#EB6E44'
      self.font_weight = BoldWeight
    end


    metrics_text = Draw.new
    metrics_text.annotate(report, 0, 0, 360, 85, 'Traffic Metrics') do
      metrics_text.gravity = NorthWestGravity
      self.font = "#{Rails.root}/app/assets/fonts/Quicksand-Bold.ttf"
      self.pointsize = 18
      self.fill = '#7C786A'
      self.font_weight = BoldWeight
    end

    traffic_metrics_text = Draw.new
    message = "Your site attracted #{asset.current_visits } visitors this week. \nThat's a #{asset.change_in_percent} #{asset.change_status} compared to the week before"
    traffic_metrics_text.annotate(report, 0, 0, 20, 285, message) do
      traffic_metrics_text.gravity = NorthGravity
      self.font = "#{Rails.root}/app/assets/fonts/Quicksand-Bold.ttf"
      self.pointsize = 12
      self.fill = '#7C786A'
      self.font_weight = BoldWeight
    end

    sessions_text = Draw.new
    sessions_text.annotate(report, 0, 0, 300, 123, "Visits: #{asset.current_visits}") do
      sessions_text.gravity = NorthWestGravity
      self.font = "#{Rails.root}/app/assets/fonts/Quicksand-Regular.ttf"
      self.pointsize = 16
      self.fill = '#8DCDC1'
      self.font_weight = BoldWeight
    end

    page_views_text = Draw.new
    page_views_text.annotate(report, 0, 0, 300, 148, "Page views: #{asset.current_page_views}") do
      page_views_text.gravity = NorthWestGravity
      self.font = "#{Rails.root}/app/assets/fonts/Quicksand-Regular.ttf"
      self.pointsize = 16
      self.fill = '#EB6E44'
      self.font_weight = BoldWeight
    end

    new_visitors_text = Draw.new
    new_visitors_text.annotate(report, 0, 0, 300, 173, "#{asset.sources.rows[0][0].pluralize}: #{asset.sources.rows[0][1]}") do
      new_visitors_text.gravity = NorthWestGravity
      self.font = "#{Rails.root}/app/assets/fonts/Quicksand-Regular.ttf"
      self.pointsize = 16
      self.fill = '#8DCDC1'
      self.font_weight = BoldWeight
    end

    returning_visitors_text = Draw.new
    returning_visitors_text.annotate(report, 0, 0, 300, 198, "#{asset.sources.rows[1][0].pluralize}: #{asset.sources.rows[1][1]}") do
      returning_visitors_text.gravity = NorthWestGravity
      self.font = "#{Rails.root}/app/assets/fonts/Quicksand-Regular.ttf"
      self.pointsize = 16
      self.fill = '#EB6E44'
      self.font_weight = BoldWeight
    end

    promo_text = Draw.new
    promo_text.annotate(report, 0, 0, 0, 5, 'Generated by Analytics Visualizer by Craft Academy Labs'.upcase) do
      promo_text.gravity = SouthGravity
      self.font = "#{Rails.root}/app/assets/fonts/Quicksand-Regular.ttf"

      self.pointsize = 10
      self.font_family = 'Arial'
      self.fill = '#EB6E44'
      self.font_weight = BoldWeight
    end

    report.composite!(header, 0, 0, OverCompositeOp)
    report.composite!(chart, 10, 80, OverCompositeOp)
    report.composite!(spider, 60, 320, OverCompositeOp)
    report.composite!(referrers, 10, 525, OverCompositeOp)
    report.composite!(countries, 280, 523, OverCompositeOp)
    report.composite!(pie, 300, 320, OverCompositeOp)
    report.composite!(platforms, 25, 285, OverCompositeOp)
    report.composite!(logo, SouthGravity, OverCompositeOp)

    #report.composite!(promo, SouthGravity, OverCompositeOp)

    report.write(File.join('public', 'tmp', file))
    return "/tmp/#{file}"
  end

  def self.generate_line_graph(dataset, file_name)
    labels = {}
    visits = []
    page_views = []
    dataset.each_with_index { |d, i| labels[i] = Date.parse(d[0]).strftime('%d/%m') }
    dataset.each { |data| visits.push data[1].to_i }
    dataset.each { |data| page_views.push data[2].to_i }

    line = Gruff::Line.new(265)
    line.theme = DEFAULT_CHART_COLORS
    line.font = "#{Rails.root}/app/assets/fonts/Quicksand-Bold.ttf"
    line.title = 'Visits and Page Views'
    line.labels = labels
    line.data :Visits, visits
    line.data :'Page Views', page_views
    line.show_vertical_markers = true
    line.left_margin=10.0
    line.right_margin=10.0
    line.label_formatting = '%.0f'
    line.write(File.join('public', 'tmp', "line_#{file_name}"))
  end

  def self.generate_pie_chart(sources, file_name)
    pie = Gruff::Pie.new(265)
    pie.theme = DEFAULT_CHART_COLORS
    pie.font = "#{Rails.root}/app/assets/fonts/Quicksand-Bold.ttf"
    pie.title = 'Returning vs New Visitors'
    pie.data sources.rows[0][0].pluralize.to_sym, sources.rows[0][1].to_i
    pie.data sources.rows[1][0].pluralize.to_sym, sources.rows[1][1].to_i
    pie.left_margin = 0
    pie.right_margin = 0
    pie.label_formatting = '%.0f'
    pie.write(File.join('public', 'tmp', "pie_#{file_name}"))
  end

  def self.generate_net_chart(os_sources, file_name)
    labels = {}
    os_sources[0..4].each_with_index { |d, i| labels[i] = d[0] }
    net = Gruff::Spider.new(os_sources[0][1].to_i.round(-1)*1.1, 235)
    net.theme = DEFAULT_CHART_COLORS
    net.font = "#{Rails.root}/app/assets/fonts/Quicksand-Bold.ttf"
    net.legend_font_size = 30
    net.labels = labels
    net.top_margin = 55
    net.left_margin = 30
    net.right_margin = 30
    net.label_formatting = '%.0f'
    os_sources[0..4].each { |data| net.data data[0].to_sym, data[1].to_i }
    net.write(File.join('public', 'tmp', "spider_#{file_name}"))
  end

  def self.generate_referers_graph(traffic_sources, file_name)
    labels = {}
    traffic_sources.rows[0..4].each_with_index { |d, i| labels[i] = d[0] }
    line = Gruff::SideBar.new(265)
    line.theme = DEFAULT_CHART_COLORS
    line.font = "#{Rails.root}/app/assets/fonts/Quicksand-Bold.ttf"
    line.title = 'Top Referring Sites'
    line.labels = labels
    line.hide_legend=true
    traffic_sources.rows[0..4].each { |data| line.data data[0], data[1].to_i }
    first_value = traffic_sources.rows[0][1].to_i
    last_value = traffic_sources.rows[-1][1].to_i
    line.maximum_value = first_value > 10 ? (first_value.to_i*1.20).to_i.round(-1) : first_value
    line.minimum_value = last_value > 10 ? (last_value.to_i*1.20).to_i.round(-1) : 0
    line.y_axis_increment = 10
    line.use_data_label=true
    line.show_labels_for_bar_values = true
    line.left_margin=0
    line.right_margin=0
    line.label_formatting = '%.0f'

    line.write(File.join('public', 'tmp', "referrers_#{file_name}"))
  end

  def self.generate_countries_graph(sources, file_name)
    acc = Gruff::Bar.new(265)
    acc.theme = DEFAULT_CHART_COLORS
    acc.font = "#{Rails.root}/app/assets/fonts/Quicksand-Bold.ttf"
    acc.title = 'Traffic by country'
    sources.rows[0..4].each { |data| acc.data data[0].to_sym, [data[1].to_i] }
    acc.left_margin = 0
    acc.right_margin = 40
    acc.minimum_value = 0
    first_value = sources.rows[0][1].to_i
    unless first_value > 100 then
      acc.y_axis_increment = 10
    end
    acc.maximum_value = first_value > 10 ? (sources.rows[0][1].to_i*1.20).to_i.round(-1) : first_value
    acc.use_data_label=true
    acc.show_labels_for_bar_values = true
    acc.hide_legend=true
    acc.marker_count = 5
    acc.label_formatting = '%.0f'
    str = ''
    sources.rows[0..4].each { |c| str += "- #{c[0]} " }
    acc.x_axis_label = str

    acc.write(File.join('public', 'tmp', "countries_#{file_name}"))

  end

  def self.group_by_weeks(basic_stats)
    array = basic_stats.rows.map { |sd| [Date.parse(sd[0]), sd[1..-1]].flatten }
    Hash[array.group_by { |a| a[0].cweek }.map { |y, items| [y, items] }]
  end

end