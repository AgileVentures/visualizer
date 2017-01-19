Given(/^I am on the "([^"]*)" page$/) do |page|
  case page
    when "Get Data"
      visit get_data_path
  end
end