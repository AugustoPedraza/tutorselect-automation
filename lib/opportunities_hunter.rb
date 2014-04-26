class OpportunitiesHunter

  attr_reader :subjects, :location

  AREA_REQUEST_TABLE_ID     = 'Main_div_opp'
  CUSTOM_MESSAGE            = "fake message"

  def initialize(selenium_directives, subject, location)
    @selenium_directives = selenium_directives
    @subjects ||= []
    @subjects << subject
    @location = location
  end

  def hunter_all
    @selenium_directives.setup_address(@location.city, @location.state.to_s, @location.zip_code.to_s)
    @selenium_directives.get_table_data_by_container_id(AREA_REQUEST_TABLE_ID).each do |opportunity|
      user_id  =opportunity[:user_profile].split('/').last.to_i
      @selenium_directives.send_message(user_id, CUSTOM_MESSAGE)
    end
  end
end
