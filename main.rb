require 'selenium-webdriver'
require 'yaml'
require 'json'

Config = YAML.load_file('config.yml')

Selenium::WebDriver::Chrome.driver_path = File.expand_path './bin/chromedriver'


class OpportunitiesSeeker
  def initialize(driver)
    @driver = driver
  end

  def online_requests
    get_requests('Main_div_onlineopp', 'Main_lb_onlineopppgNext')
  end

  def area_requests
    get_requests('Main_div_sel', 'Main_lb_SelpgNext')
  end

  private
    def get_requests(table_container_id, next_page_id)
      @page_number = 0
      @last_id = 0

      opportunities = []

      opportunities << extract_opportunities_from_table(table_container_id)
      opportunities << extract_opportunities_from_table(table_container_id) while navigate_to_next_page(next_page_id)

      opportunities.flatten!
    end

    def extract_opportunities_from_table(table_container_id)
      @driver.find_element(:id, table_container_id).find_elements(:tag_name, 'tr')
        .map { |tr| tr.find_elements(:tag_name, 'td') }
        .map do |user_td, subject_td, date_td|
          extract_opportunity_from_table_row(user_td, subject_td, date_td)
        end
    end

    def extract_opportunity_from_table_row(user_td, subject_td, date_td)
      opportunity = {}
      @last_id = @last_id + 1
      opportunity[:id]           = @last_id
      opportunity[:username]     = user_td.text
      opportunity[:user_profile] = user_td.find_element(:tag_name, 'a').attribute 'href'
      opportunity[:subject]      = subject_td.text
      opportunity[:date]         = date_td.text

      opportunity
    end

    def navigate_to_next_page(next_page_id)
      begin
        if next_page_el = @driver.find_element(:id, next_page_id)
          next_page_el.click
          @page_number = @page_number + 1
          puts "Getting request from page n° #{@page_number}..."
          true #return
        end
      rescue Selenium::WebDriver::Error::NoSuchElementError
        puts "="*50
        puts "No more pages!!!"
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


puts "="*50
puts "Getting online opportunities..."
puts "="*50

opportunities = opportunities_seeker.online_requests
puts "#{opportunities.count} online opportunities got."
open("online_requests.txt", "w") { |io| io.write JSON.pretty_generate(opportunities) }


#========================================


puts "="*50
puts "Getting area opportunities..."
puts "="*50

opportunities = opportunities_seeker.area_requests
puts "#{opportunities.count} area opportunities got."

open("area_requests.txt", "w") { |io| io.write JSON.pretty_generate(opportunities) }

driver.quit
