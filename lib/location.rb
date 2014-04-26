class Location

  attr_accessor :city, :state, :zip_code

  def initialize(values)
    @city  = values[:city]
    @state    = values[:state]
    @zip_code = values[:zip_code]
  end
end
