$LOAD_PATH << File.join(File.dirname(__FILE__), '.', 'lib')

require 'selenium-webdriver'
require 'yaml'
require 'selenium_directives'
require 'location'
require 'opportunities_hunter'

Message = "Hello I hope your studies are going well for spanish!
  We currently have online tutors available! If you would like to get started send us a message or email us to Letsgettutoring@gmail.com"


Selenium::WebDriver::Chrome.driver_path = File.expand_path './bin/chromedriver'
Config = YAML.load_file('config.yml')

begin
  driver = Selenium::WebDriver.for :chrome

  opp_hunter = OpportunitiesHunter.new(SeleniumDirectives.new(driver), Config['user'], Config['pass'])

  location = Location.new({city: 'San Jose', state: 'CA', zip_code: '95111'})

  opp_hunter.hunter_all(location, 'Twitter Boostrap', Message)
rescue Exception => e
  puts e
  puts e.backtrace.join("\n")
end

driver.quit
