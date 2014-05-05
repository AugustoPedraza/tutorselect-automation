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


    puts "hunter opportunities for '#{subject}' subject"
    @selenium_directives.get_table_data_by_container_id(AREA_REQUEST_TABLE_ID).values.flatten.each do |opportunity|

      next unless opportunity[:subject].downcase.include?(subject.downcase)
      request_id  = opportunity[:request_id].split('trid=').last.to_i

      begin
        puts "Sending message to request_id : #{request_id}"

        @selenium_directives.send_message(request_id, message)
        sent_msg_counter += 1

        puts "%d. Message sent to id request = %d" % [sent_msg_counter,  request_id]
      rescue Exception => e
        puts e
        puts e.backtrace.join("\n")
      end
    end

    puts "="*50
    puts "#{sent_msg_counter} messages #{sent_msg_counter > 1 ? 'were' : 'was'} sent for the '#{subject}' subject"
    puts "="*50

  end
end
