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

    @welcome_message = @driver.find_element(:class, WELCOME_MESSAGE_CLASS).text
  end

  def welcome_message
    @welcome_message
  end
end
