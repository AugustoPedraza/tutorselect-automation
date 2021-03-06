class SeleniumDirectives
  LOGIN_URL                 = "https://www.tutorselect.com/login"
  USERNAME_ID               = 'Main_LoginUser_UserName'
  PASSWORD_ID               = 'Main_LoginUser_Password'
  WELCOME_MESSAGE_CLASS     = 'username'

  EDIT_ADDRESS_PROFILE_ID   = 'Main_lb_detaddr_edit'
  CITY_TEXTBOX_ID           = 'Main_tb_addrCity'
  ZIPCODE_TEXTBOX_ID        = 'Main_tb_addrZip'
  STATES_SELECT_ID          = 'Main_ddl_States'
  ADDRESS_PROFILE_SUBMIT_ID = 'Main_lb_addrSave'

  DISTANCE_SELECT_ID        = 'Main_ddl_oppDist'

  DISTANCE_DEFAULT          = '50'

  NEXT_PAGE_ID              = 'Main_lb_opppgNext'

  MESSAGE_TEXT_BOX_ID       = 'Main_tbMSG'
  SEND_MESSAGE_BUTTON_ID    = 'Main_bs'

  MESSAGE_SEND_RESULT_ID    = 'Main_lbl_msgError'

  SUCCESS_MESSAGE           = 'Your message was sent!'

  def initialize(driver)
    @driver = driver
    @current_page = 1
  end

  def login(email, password)
    @driver.navigate.to (LOGIN_URL)

    @driver.find_element(:id, USERNAME_ID).send_keys email
    @driver.find_element(:id, PASSWORD_ID).send_keys password

    @driver.find_element(:id, 'Main_LoginUser_LoginButton').click

    logged?
  end

  def logged?
    ! welcome_message.nil?
  end

  def welcome_message
    begin
      @driver.find_element(:class, WELCOME_MESSAGE_CLASS).text
    rescue
      nil
    end
  end

  def setup_address(city, state, zip_code)
    raise 'invalid login' unless logged?

    @driver.navigate.to 'https://www.tutorselect.com/portal/myaccount.aspx'

    @driver.find_element(:id, EDIT_ADDRESS_PROFILE_ID).click

    city_textbox = @driver.find_element(:id, CITY_TEXTBOX_ID)
    city_textbox.clear
    city_textbox.send_keys(city)

    zip_textbox = @driver.find_element(:id, ZIPCODE_TEXTBOX_ID)
    zip_textbox.clear
    zip_textbox.send_keys(zip_code)

    dropDownMenu = @driver.find_element(:id, STATES_SELECT_ID)
    option       = Selenium::WebDriver::Support::Select.new(dropDownMenu)
    option.select_by(:value, state)

    @driver.find_element(:id, ADDRESS_PROFILE_SUBMIT_ID).click
    @driver.navigate.to 'https://www.tutorselect.com/portal/opportunities.aspx'
  end

  def get_table_data_by_container_id(table_div_container_id)
    dropDownMenu = @driver.find_element(:id, DISTANCE_SELECT_ID)
    option       = Selenium::WebDriver::Support::Select.new(dropDownMenu)
    option.select_by(:value, DISTANCE_DEFAULT)

    opportunities = {}

    current_page = 1
    while current_page
      puts "Getting information of page #{current_page}..."
      opportunities[current_page] = get_opportunities_for_table_container(table_div_container_id)

      current_page = next_page
    end

    opportunities
  end

  def send_message(request_id, message)
    request_url_format_string = "https://www.tutorselect.com/portal/viewcprofile.aspx?trid=%d"
    file_path = File.join(File.dirname(__FILE__), '..', "data")

    url = request_url_format_string % [request_id]
    puts "Driver navigation to #{url}"
    @driver.navigate.to(url)


    text_box = @driver.find_element(:id, MESSAGE_TEXT_BOX_ID)
    text_box.clear
    text_box.send_keys(message)

    @driver.save_screenshot "#{file_path}/#{request_id}_begin.png"

    @driver.find_element(:id, SEND_MESSAGE_BUTTON_ID).click

    message = @driver.find_element(:id, MESSAGE_SEND_RESULT_ID).text

    @driver.save_screenshot "#{file_path}/#{request_id}_end.png"

    if message == SUCCESS_MESSAGE
      true
    else
      raise StandardError, message
    end
  end

  private
    def get_opportunities_for_table_container(table_div_container_id)
      xpath = "//div[@id='#{table_div_container_id}']/table/tbody/tr"
      rows = @driver.find_elements(:xpath, xpath).map { |tr| tr.find_elements(:tag_name, 'td') }

      rows.map do |td_user, td_subject, td_date, others|
        opportunity = {}

        opportunity[:username]     = td_user.text
        opportunity[:request_id] = td_user.find_element(:tag_name, 'a').attribute 'href'
        opportunity[:subject]      = td_subject.text
        opportunity[:date]         = td_date.text

        opportunity
      end
    end

    def next_page
      begin
        next_page_el = @driver.find_element(:id, NEXT_PAGE_ID)
        next_page_el.click
        @current_page = @current_page + 1
      rescue Selenium::WebDriver::Error::NoSuchElementError
        @current_page = 1
        nil
      end
    end
end
