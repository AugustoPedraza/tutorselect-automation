require 'spec_helper'

describe OpportunitiesHunter do
  describe "initialization" do
    context "with valid credentials" do
      it "create a valid object" do
        fake_selenium_directives = double(SeleniumDirectives)

        sut = OpportunitiesHunter.new(fake_selenium_directives, "fake@email.com", "fake_password")
        expect(sut.account_email).to eql("fake@email.com")
        expect(sut.account_password).to eql("fake_password")
      end
    end
  end

  describe ".hunter_all" do
    context "selenium directives instance already logged" do
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

          allow(selenium_directives_mock).to receive(:logged?).and_return(true).ordered
          allow(selenium_directives_mock).to receive(:setup_address).with(kind_of(String), kind_of(String), kind_of(String)).ordered
          allow(selenium_directives_mock).to receive(:get_table_data_by_container_id).with(kind_of(String)).and_return(fake_opportunities).ordered
          allow(selenium_directives_mock).to receive(:send_message).with(kind_of(Integer), kind_of(String)).ordered

          fake_location  = Location.new({ city: "fake city", state: :NY, zip_code: 11011 })
          sut = OpportunitiesHunter.new(selenium_directives_mock, "dummy@email.com", "dummy_password")

          sut.hunter_all(fake_location, "fake subject")

          expect(selenium_directives_mock).to have_received(:setup_address).once.with("fake city", "NY", "11011")

          [111, 222, 333, 444, 555].each do |fake_id|
            expect(selenium_directives_mock).to have_received(:send_message).once.with(fake_id, 'fake message')
          end
        end
      end
    end

    context "receive a selenium directives instance not logged" do
      it "try login" do
        selenium_directives_mock = double('selenium_directives')

        allow(selenium_directives_mock).to receive(:logged?).and_return(false).ordered
        allow(selenium_directives_mock).to receive(:login).with(kind_of(String), kind_of(String)).ordered
        allow(selenium_directives_mock).to receive(:setup_address).with(kind_of(String), kind_of(String), kind_of(String))
        allow(selenium_directives_mock).to receive(:get_table_data_by_container_id).with(kind_of(String)).and_return([])
        allow(selenium_directives_mock).to receive(:send_message).with(kind_of(Integer), kind_of(String))

        dummy_location  = Location.new({ city: "fake city", state: :NY, zip_code: 11011 })
        sut = OpportunitiesHunter.new(selenium_directives_mock, "fake@email.com", "fake_password")
        sut.hunter_all(dummy_location, 'dummy subject')

        expect(selenium_directives_mock).to have_received(:login).once.with("fake@email.com", "fake_password")
      end
    end
  end
end
