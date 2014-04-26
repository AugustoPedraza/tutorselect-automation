require 'spec_helper'

describe OpportunitiesHunter do
  describe "initialization" do
    context "with a single subject a location and a valid selenium directive instance" do
      it "create a valid object" do
        fake_location = Location.new({ address: "fake address", state: :NY, zip_code: "10001" })
        fake_selenium_directives = double(SeleniumDirectives)

        sut = OpportunitiesHunter.new(fake_selenium_directives, :spanish, fake_location)
        expect(sut.subjects).to match_array ([:spanish])
        expect(sut.location).to equal(fake_location)
      end
    end
  end

  describe ".hunter_all" do
    context "receive a selenium directives instance already logged" do
      context "5 opportunities founded" do
        it "send 5 messages" do
          selenium_directives_mock = double('selenium_directives')

          fake_opportunities = []
           5.times do |i|
            i = i + 1
            fake_opportunities <<
              {
                username:     "fake username#{i}",
                user_profile: "http://fakes/#{i.to_s * 3}",
                subject:      "fake subject",
                date:         "fake date#{i}"
              }
          end

          allow(selenium_directives_mock).to receive(:setup_address).with(kind_of(String), kind_of(String), kind_of(String)).ordered
          allow(selenium_directives_mock).to receive(:get_table_data_by_container_id).with(kind_of(String)).and_return(fake_opportunities).ordered
          allow(selenium_directives_mock).to receive(:send_message).with(kind_of(Integer), kind_of(String)).ordered

          dummy_location  = Location.new({ city: "fake city", state: :NY, zip_code: 11011 })
          sut = OpportunitiesHunter.new(selenium_directives_mock, "fake subject", dummy_location)

          sut.hunter_all

          expect(selenium_directives_mock).to have_received(:setup_address).once.with("fake city", "NY", "11011")

          [111, 222, 333, 444, 555].each do |fake_id|
            expect(selenium_directives_mock).to have_received(:send_message).once.with(fake_id, 'fake message')
          end
        end
      end
    end
  end
end
