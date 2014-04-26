class OpportunitiesHunter

  attr_reader :subjects, :location

  def initialize(subject, location)
    @subjects ||= []
    @subjects << subject
    @location = location
  end
end