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

  DISTANCE_DEFAULT          = '5'

  def initialize(driver)
    @driver = driver
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
  end

  def get_table_data_by_container_id(table_div_container_id)
    dropDownMenu = @driver.find_element(:id, DISTANCE_SELECT_ID)
    option       = Selenium::WebDriver::Support::Select.new(dropDownMenu)
    option.select_by(:value, DISTANCE_DEFAULT)

    xpath = "//div[@id='#{table_div_container_id}']/table/tbody/tr"

    rows = @driver.find_elements(:xpath, xpath).map { |tr| tr.find_elements(:tag_name, 'td') }
    rows.map do |td_user, td_subject, td_date, others|
      opportunity = {}

      opportunity[:username]     = td_user.text
      opportunity[:user_profile] = td_user.find_element(:tag_name, 'a').attribute 'href'
      opportunity[:subject]      = td_subject.text
      opportunity[:date]         = td_date.text

      opportunity
    end
  end
end
