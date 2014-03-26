require 'selenium-webdriver'
require 'yaml'
require 'json'

require './opportunities_seeker'

Config = YAML.load_file('config.yml')

Selenium::WebDriver::Chrome.driver_path = File.expand_path './bin/chromedriver'


def login(driver)
  driver.navigate.to "https://www.tutorselect.com/login"
  driver.find_element(:id, 'Main_LoginUser_UserName').send_keys Config['user']
  driver.find_element(:id, 'Main_LoginUser_Password').send_keys Config['pass']

  driver.find_element(:id, 'Main_LoginUser_LoginButton').click
end

def change_address(driver, city, state, zip_code)
  puts "Changing location to %s(%s - %s)..." % [zip_code, city, state]

  driver.navigate.to 'https://www.tutorselect.com/portal/myaccount.aspx'
  driver.find_element(:id, 'Main_lb_detaddr_edit').click

  city_textbox = driver.find_element(:id, 'Main_tb_addrCity')
  city_textbox.clear
  city_textbox.send_keys(city)

  zip_textbox = driver.find_element(:id, 'Main_tb_addrZip')
  zip_textbox.clear
  zip_textbox.send_keys(zip_code)

  dropDownMenu = driver.find_element(:id, 'Main_ddl_States')
  option       = Selenium::WebDriver::Support::Select.new(dropDownMenu)
  option.select_by(:value, state)


  driver.find_element(:id, 'Main_lb_addrSave').click
end

driver = Selenium::WebDriver.for :chrome
login(driver)

opportunities_seeker = OpportunitiesSeeker.new driver

places = [
  # { zip_code: '08544', city: 'Princeton',     state: 'NJ' },
  # { zip_code: '02138', city: 'Cambridge',     state: 'MA' },
  # { zip_code: '06520', city: 'New Haven',     state: 'CT' },
  # { zip_code: '10027', city: 'New York',      state: 'NY' },
  # { zip_code: '60637', city: 'Chicago',       state: 'IL' },
  # { zip_code: '27708', city: 'Durham',        state: 'NC' },
  # { zip_code: '02139', city: 'Cambridge',     state: 'MA' },
  # { zip_code: '19104', city: 'Philadelphia',  state: 'PA' },
  # { zip_code: '91125', city: 'Pasadena',      state: 'CA' },
  { zip_code: '03755', city: 'Hanover',       state: 'NH' }
]

places.each do |place|
  zip_code = place[:zip_code]
  city     = place[:city]
  state    = place[:state]

  puts "="*50
  puts "Getting area opportunities for %s(%s - %s)..." % [zip_code, city, state]

  change_address(driver, city, state, zip_code)

  driver.navigate.to 'https://www.tutorselect.com/portal/opportunities.aspx'

  opp = opportunities_seeker.area_requests
  opportunities_count = opp.count

  puts "\n%d opportunities got close to %s(%s - %s)." % [opportunities_count, zip_code, city, state]

  file_name = "data/%d_requests_found_in_%s_%s_%s.txt" % [opportunities_count, zip_code, city, state]
  open(file_name, "w") { |io| io.write JSON.pretty_generate(opp) }
  puts "="*50
end
=begin
puts "="*50
puts "Getting online opportunities..."
puts "="*50

opportunities = opportunities_seeker.online_requests
puts "#{opportunities.count} online opportunities got."
open("online_requests.txt", "w") { |io| io.write JSON.pretty_generate(opportunities) }


#========================================
=end
driver.quit
