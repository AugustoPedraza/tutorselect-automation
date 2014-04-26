require 'spec_helper'

describe OpportunitiesHunter do
  context "initialization with a single subject a location and a valid selenium directive instance" do
    it "create a valid object" do
      fake_location = Location.new({ address: "fake address", state: :NY, zip_code: "10001" })
      fake_selenium_directives = double(SeleniumDirectives)

      sut = OpportunitiesHunter.new(fake_selenium_directives, :spanish, fake_location)
      expect(sut.subjects).to match_array ([:spanish])
      expect(sut.location).to equal(fake_location)
    end
  end
end
