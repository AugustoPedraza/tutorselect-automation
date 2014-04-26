class OpportunitiesHunter

  attr_reader :subjects, :location

  def initialize(selenium_directives, subject, location)
    @selenium_directives = selenium_directives
    @subjects ||= []
    @subjects << subject
    @location = location
  end
end
