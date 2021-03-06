require 'spec_helper'

describe Location do
  context "initialization with a valid hash" do
    it "assign the attributes" do
      values = { city: 'fake city 203', zip_code: '23011', state: :NY }
      sut = Location.new(values)

      expect(sut.city).to eql('fake city 203')
      expect(sut.zip_code).to eql('23011')
      expect(sut.state).to equal(:NY)
    end
  end
end
