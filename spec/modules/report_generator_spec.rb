describe AnalyticsPeriod do

  let(:basic_increase_stats) { double(Google::Apis::AnalyticsV3::GaData, rows: [['20161118', '50', '100'],
                                                                                ['20161119', '50', '100'],
                                                                                ['20161120', '50', '100'],
                                                                                ['20161121', '50', '100'],
                                                                                ['20161122', '50', '100'],
                                                                                ['20161123', '50', '100'],
                                                                                ['20161124', '50', '100'],
                                                                                ['20161125', '100', '200'],
                                                                                ['20161126', '100', '200'],
                                                                                ['20161127', '100', '200'],
                                                                                ['20161128', '100', '200'],
                                                                                ['20161129', '100', '200'],
                                                                                ['20161130', '100', '200'],
                                                                                ['20161201', '100', '200']],
                                      query: double(Google::Apis::AnalyticsV3::GaData::Query,
                                                    start_date: '20161118',
                                                    end_date: '20161201')
  ) }

  let(:basic_decrease_stats) { double(Google::Apis::AnalyticsV3::GaData, rows: [['20161118', '43', '73'],
                                                                                ['20161119', '34', '51'],
                                                                                ['20161120', '23', '46'],
                                                                                ['20161121', '42', '95'],
                                                                                ['20161122', '47', '85'],
                                                                                ['20161123', '52', '80'],
                                                                                ['20161124', '60', '93'],
                                                                                ['20161125', '1', '53'],
                                                                                ['20161126', '1', '41'],
                                                                                ['20161127', '1', '61'],
                                                                                ['20161128', '1', '81'],
                                                                                ['20161129', '1', '84'],
                                                                                ['20161130', '1', '100'],
                                                                                ['20161201', '1', '60']],
                                      query: double(Google::Apis::AnalyticsV3::GaData::Query,
                                                    start_date: '20161118',
                                                    end_date: '20161201')
  ) }

  let(:service) { double('Mock', get_ga_data: OpenStruct.new(profile_id: "ga:", start_date: "2017-01-05", end_date: "2017-01-18", metrics: "ga:sessions, ga:uniquePageviews",
      dimensions: 'ga:date')) }
  let(:params) { {} }

  subject { described_class.new(service, params) }

  describe 'generates a comparison text for increased traffic' do
    let!(:period) { subject.calculate_traffic(basic_increase_stats) }

    it 'sets #current_start_date' do
      expect(period.current_start_date).to eq Date.parse('20161125')
    end

    it 'sets #current_end_date' do
      expect(period.current_end_date).to eq Date.parse('20161201')
    end


    it 'sets #current_visits' do
      expect(period.current_visits).to eq 700
    end

    it 'sets #previous_visitss' do
      expect(period.previous_visits).to eq 350
    end

    it 'sets #current_page_views' do
      expect(period.current_page_views).to eq 1400
    end

    it 'sets #previous_page_views' do
      expect(period.previous_page_views).to eq 700
    end

    it 'generates a string with %' do
      expect(period.change_in_percent).to eq '100%'
    end


  end


end