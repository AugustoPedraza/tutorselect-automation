class OpportunitiesHunter

  attr_reader :account_email, :account_password

  AREA_REQUEST_TABLE_ID     = 'Main_div_opp'
  DEFAULT_MESSAGE           = 'fake message'

  def initialize(selenium_directives, email, password)
    @selenium_directives  = selenium_directives
    @account_email        = email
    @account_password     = password
  end

  def hunter_all(location, subject, message = '')
    message = message.empty? ? DEFAULT_MESSAGE : message

    unless(@selenium_directives.logged?)
      @selenium_directives.login(@account_email, @account_password)
    end

    @selenium_directives.setup_address(location.city, location.state.to_s, location.zip_code.to_s)

    sent_msg_counter = 0

    @selenium_directives.get_table_data_by_container_id(AREA_REQUEST_TABLE_ID).each do |opportunity|
      next unless opportunity[:subject].downcase.include?(subject.downcase)
      request_id  = opportunity[:user_profile].split('/').last.to_i

      begin
        @selenium_directives.send_message(request_id, DEFAULT_MESSAGE)
        sent_msg_counter += 1
        puts "%d. Message sent to id request = %d" % [sent_msg_counter,  id_request]
      rescue Exception => e
      end
    end

    puts "="*50
    puts "#{sent_msg_counter} messages were sent for the '#{subject}' subject"
    puts "="*50

  end
end
