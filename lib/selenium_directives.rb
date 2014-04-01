class SeleniumDirectives
  LOGIN_URL             = "https://www.tutorselect.com/login"
  USERNAME_ID           = 'Main_LoginUser_UserName'
  PASSWORD_ID           = 'Main_LoginUser_Password'
  WELCOME_MESSAGE_CLASS = 'username'

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
  end
end
