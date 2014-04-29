class OpportunitiesHunter

  attr_reader :account_email, :account_password

  AREA_REQUEST_TABLE_ID     = 'Main_div_opp'
  CUSTOM_MESSAGE            = "fake message"

  def initialize(selenium_directives, email, password)
    @selenium_directives  = selenium_directives
    @account_email        = email
    @account_password     = password
  end

  def hunter_all(location, subject)
    unless(@selenium_directives.logged?)
      @selenium_directives.login(@account_email, @account_password)
    end

    @selenium_directives.setup_address(location.city, location.state.to_s, location.zip_code.to_s)

    @selenium_directives.get_table_data_by_container_id(AREA_REQUEST_TABLE_ID).each do |opportunity|
      next unless opportunity[:subject].include?(subject)
      user_id  = opportunity[:user_profile].split('/').last.to_i
      @selenium_directives.send_message(user_id, CUSTOM_MESSAGE)
    end

  end
end
