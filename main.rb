$LOAD_PATH << File.join(File.dirname(__FILE__), '.', 'lib')

require 'selenium-webdriver'
require 'yaml'
require 'selenium_directives'
require 'location'
require 'opportunities_hunter'

Selenium::WebDriver::Chrome.driver_path = File.expand_path './bin/chromedriver'
Config = YAML.load_file('config.yml')

begin
  driver = Selenium::WebDriver.for :chrome

  opp_hunter = OpportunitiesHunter.new(SeleniumDirectives.new(driver), Config['user'], Config['pass'])

  loop do
    puts "Input the location, state and zip code commas separated, for setup your address (i.e. San Jose,CA,95111):"
    input = gets.chomp
    break if input.downcase.include?('exit')
    city, state, zip_code = input.split(',').map{ |s| s.gsub(/\s{2,}/, '')}
    location = Location.new({city: city, state: state, zip_code: zip_code})

    opp_hunter.hunter_all(location, Config['subject'], Config['message'])
  end
rescue Exception => e
  puts e
  puts e.backtrace.join("\n")
end

driver.quit
