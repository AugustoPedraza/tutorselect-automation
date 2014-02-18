require 'selenium-webdriver'

Selenium::WebDriver::Chrome.driver_path = File.expand_path './bin/chromedriver'
driver = Selenium::WebDriver.for :chrome
driver.navigate.to "http://www.tutorselect.com/"

element = driver.find_element(:id, 'sc_tbs')
element.send_keys "math"


element = driver.find_element(:id, 'sc_tbl')
element.send_keys "10003"

driver.find_element(:id, 'sc_bs').click

sleep 10


puts driver.title
driver.quit
