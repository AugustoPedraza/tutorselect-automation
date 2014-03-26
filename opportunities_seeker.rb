class OpportunitiesSeeker
  def initialize(driver)
    @driver = driver
  end

  def online_requests
    get_requests('Main_div_onlineopp', 'Main_lb_onlineopppgNext')
  end

  def area_requests
    get_requests('Main_div_opp', 'Main_lb_opppgNext')
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
