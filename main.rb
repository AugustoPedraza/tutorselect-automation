require 'selenium-webdriver'
require 'yaml'

Config = YAML.load_file('config.yml')

Selenium::WebDriver::Chrome.driver_path = File.expand_path './bin/chromedriver'


class OpportunitiesSeeker
  def initialize(driver)
    @driver = driver
  end

  def online_requests
    opportunities = []

    opportunities << extract_opportunities_from_table
    opportunities << extract_opportunities_from_table while navigate_to_next_page

    opportunities.flatten!
  end

  private
    def extract_opportunities_from_table
      @driver.find_element(:id, 'Main_div_onlineopp').find_elements(:tag_name, 'tr')
        .map { |tr| tr.find_elements(:tag_name, 'td') }
        .map do |user_td, subject_td, date_td|
          extract_opportunity_from_table_row(user_td, subject_td, date_td)
        end
    end

    def extract_opportunity_from_table_row(user_td, subject_td, date_td)
      opportunity = {}
      opportunity[:username]     = user_td.text
      opportunity[:user_profile] = user_td.find_element(:tag_name, 'a').attribute 'href'
      opportunity[:subject]      = subject_td.text
      opportunity[:date]         = date_td.text

      opportunity
    end

    def navigate_to_next_page
      begin
        while next_page_el = @driver.find_element(:id, 'Main_lb_onlineopppgNext')
          next_page_el.click

          true #return
        end
      rescue Selenium::WebDriver::Error::NoSuchElementError
        puts "="*50
        puts "ERROR!!!"
        puts "="*50

        false #return
      end
    end
end

def login(driver)
  driver.find_element(:id, 'Main_LoginUser_UserName').send_keys Config['user']
  driver.find_element(:id, 'Main_LoginUser_Password').send_keys Config['pass']

  driver.find_element(:id, 'Main_LoginUser_LoginButton').click
end

driver = Selenium::WebDriver.for :chrome
driver.navigate.to "https://www.tutorselect.com/login"
login(driver)

opportunities_seeker = OpportunitiesSeeker.new driver

open("requests.txt", "w") { |io| io.write opportunities_seeker.online_requests }

driver.quit
