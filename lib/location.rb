class Location

  attr_accessor :address, :state, :zip_code

  def initialize(values)
    @address  = values[:address]
    @state    = values[:state]
    @zip_code = values[:zip_code]
  end
end
