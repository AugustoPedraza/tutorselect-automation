require 'spec_helper'

describe OpportunitiesHunter do
  context "initialization with a single subject" do
    it "create a object" do
      sut = OpportunitiesHunter.new(:spanish)
      expect(sut.subjects).to match_array ([:spanish])
    end
  end
end
