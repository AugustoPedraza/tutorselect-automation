require 'selenium-webdriver'
require 'yaml'
require 'json'
require './lib/selenium_directives'
require './lib/zip_codes_reader'

AREA_REQUEST_TABLE_ID     = 'Main_div_opp'
VALID_STATES              = ["AK", "AL", "AR", "AZ", "CA", "CO", "CT", "DC", "DE", "FL",
  "GA", "HI", "IA", "ID", "IL", "IN", "KS", "KY", "LA", "MA",
  "MD", "ME", "MI", "MN", "MO", "MS", "MT", "NC", "ND", "NE",
  "NH", "NJ", "NM", "NV", "NY", "OH", "OK", "OR", "PA", "RI",
  "SC", "SD", "TN", "TX", "UT", "VA", "VT", "WA", "WI", "WV",
  "WY"]

#This class should be "disposable"
class OpportunitiesSearcher
  def self.get_opportunities_for(city, state, zip_code)
    msg = ''
    file_path = get_file_path_for(city, state, zip_code)

    unless File.exists?(file_path)
      begin
        session.setup_address(city, state, zip_code)

        opp = session.get_table_data_by_container_id(AREA_REQUEST_TABLE_ID).values.flatten #The id's keys aren't important

        puts "="*50
        puts opp
        puts "="*50

        if opp.nil? || opp.empty?
          File.open(file_path, "w"){}
          msg = "not result found for %s(%s - %s)" % [zip_code, city, state]
        else
          save_result(opp, file_path)
          msg = "%d opportunities found for %s(%s - %s)" % [opp.count,zip_code, city, state]
        end
      rescue Selenium::WebDriver::Error::StaleElementReferenceError => e
        puts "StaleElementReferenceError found.\nWaiting 10 seconds..."
        sleep(10)
      end
    else
      msg = 'The zip code was just used.'
    end

    msg
  end

  def self.finish
    @@driver.quit
  end

  private
    def self.create_chrome_driver
      Selenium::WebDriver::Chrome.driver_path = File.expand_path './bin/chromedriver'
      @@driver = Selenium::WebDriver.for :chrome

      @@driver
    end

    def self.session
      @@session ||= start_logged_session
    end

    def self.start_logged_session
      config = YAML.load_file('config.yml')
      session = SeleniumDirectives.new(create_chrome_driver)
      session.login(config['user'], config['pass'])

      session
    end

    def self.save_result(opportunities, file_path)
      headers = opportunities.first.keys

      CSV.open(file_path, "wb", write_headers: true, headers: headers) do |csv|
        opportunities.each do |opp|
          data = opp.values
          data[1] = data[1].split('=').last #get just the id of the user's profile
          csv << data
        end
      end

      file_path
    end

    def self.get_file_path_for(city, state, zip_code)
      formatted_city = city.gsub(/\s+/, '_')
      file_name = "%s_%s_%s.csv" % [zip_code, state, formatted_city]

      FileUtils.mkdir("./data/#{state}") unless File.directory?("./data/#{state}")
      File.join("./data/#{state}", file_name)
    end
end

ZipCodesReader.foreach(File.join('./data/zip_codes.csv')) do |data|
  data.delete_if { |k, v| v.nil? || k.nil? || !VALID_STATES.include?(data[:state]) || v.empty?}
  next if data.empty?
  puts "Searching opportunities for #{data}"

  puts OpportunitiesSearcher.get_opportunities_for(data[:city], data[:state], data[:zip])
end

OpportunitiesSearcher.finish
