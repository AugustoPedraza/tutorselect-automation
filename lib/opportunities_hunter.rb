class OpportunitiesHunter

  attr_accessor :subjects

  def initialize(subject)
    @subjects ||= []
    @subjects << subject
  end
end