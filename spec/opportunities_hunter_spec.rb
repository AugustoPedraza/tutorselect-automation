require 'spec_helper'

describe OpportunitiesHunter do
  describe "initialization" do
    before { @selenium_directives_mock = double(SeleniumDirectives) }
    subject { OpportunitiesHunter.new(@selenium_directives_mock, "fake@email.com", "fake_password") }

    it "set email and password" do
      expect(subject.account_email).to eql("fake@email.com")
      expect(subject.account_password).to eql("fake_password")
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
                request_id: "http://fakes/viewcprofile.aspx?trid=#{i.to_s * 3}",
                subject:      "fake subject",
                date:         "fake date#{i}"
              }
          end

          allow(selenium_directives_mock).to receive(:logged?).and_return(true).ordered
          allow(selenium_directives_mock).to receive(:setup_address).with(kind_of(String), kind_of(String), kind_of(String)).ordered
          allow(selenium_directives_mock).to receive(:get_table_data_by_container_id).with(kind_of(String)).and_return({1 => fake_opportunities}).ordered
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

      context "12 opportunities founded" do
        it "send messages just for the specified subject" do
          selenium_directives_mock = double('selenium_directives')

          fake_opportunities = []
          10.times do |i|
            i = i + 1
            fake_opportunities <<
              {
                username:     "fake username#{i}",
                request_id: "http://fakes/viewcprofile.aspx?trid=#{i.to_s * 3}",
                subject:      %w{Math Science Chemistry Geometry Accounting Physics SAT Spanish Statistics}.sample,
                date:         "fake date#{i}"
              }
          end

          fake_opportunities << { username: "fake usr707", request_id: "http://fakes/viewcprofile.aspx?trid=707",
            subject: "fake subject", date: "fake date77"
          }

          fake_opportunities << { username: "fake usr808", request_id: "http://fakes/viewcprofile.aspx?trid=808",
            subject: "fake subject", date: "fake date808"
          }


          fake_opportunities << { username: "fake usr909", request_id: "http://fakes/viewcprofile.aspx?trid=909",
            subject: "fake subject", date: "fake date909"
          }

          allow(selenium_directives_mock).to receive(:logged?).and_return(true).ordered
          allow(selenium_directives_mock).to receive(:setup_address).with(kind_of(String), kind_of(String), kind_of(String)).ordered
          allow(selenium_directives_mock).to receive(:get_table_data_by_container_id).with(kind_of(String)).and_return({1 => fake_opportunities}).ordered
          allow(selenium_directives_mock).to receive(:send_message).with(kind_of(Integer), kind_of(String)).ordered

          fake_location  = Location.new({ city: "fake city", state: :NY, zip_code: 11011 })
          sut = OpportunitiesHunter.new(selenium_directives_mock, "dummy@email.com", "dummy_password")

          sut.hunter_all(fake_location, "fake subject")

          expect(selenium_directives_mock).to have_received(:setup_address).once.with("fake city", "NY", "11011")

          expect(selenium_directives_mock).to have_received(:send_message).with(any_args()).exactly(3)

          [707, 808, 909].each do |fake_id|
            expect(selenium_directives_mock).to have_received(:send_message).once.with(fake_id, 'fake message')
          end
        end

        context "error to sent a message" do
          it "manage the error a sent the others messages" do
            selenium_directives_mock = double('selenium_directives')

            fake_opportunities = []
            10.times do |i|
              i = i + 1
              fake_opportunities <<
                {
                  username:     "fake username#{i}",
                  request_id: "http://fakes/viewcprofile.aspx?trid=#{i.to_s * 3}",
                  subject:      %w{Math Science Chemistry Geometry Accounting Physics SAT Spanish Statistics}.sample,
                  date:         "fake date#{i}"
                }
            end

            fake_opportunities << { username: "fake usr707", request_id: "http://fakes/viewcprofile.aspx?trid=707",
              subject: "fake subject", date: "fake date77"
            }

            fake_opportunities << { username: "fake usr808", request_id: "http://fakes/viewcprofile.aspx?trid=808",
              subject: "fake subject", date: "fake date808"
            }


            fake_opportunities << { username: "fake usr909", request_id: "http://fakes/viewcprofile.aspx?trid=909",
              subject: "fake subject", date: "fake date909"
            }

            allow(selenium_directives_mock).to receive(:logged?).and_return(true).ordered
            allow(selenium_directives_mock).to receive(:setup_address).with(kind_of(String), kind_of(String), kind_of(String)).ordered
            allow(selenium_directives_mock).to receive(:get_table_data_by_container_id).with(kind_of(String)).and_return({1 => fake_opportunities}).ordered
            allow(selenium_directives_mock).to receive(:send_message).with(kind_of(Integer), kind_of(String)).ordered
            allow(selenium_directives_mock).to receive(:send_message).with(808, 'fake message').and_raise('FailMessageSending')

            fake_location  = Location.new({ city: "fake city", state: :NY, zip_code: 11011 })
            sut = OpportunitiesHunter.new(selenium_directives_mock, "dummy@email.com", "dummy_password")

            sut.hunter_all(fake_location, "fake subject")

            expect(selenium_directives_mock).to have_received(:setup_address).once.with("fake city", "NY", "11011")

            expect(selenium_directives_mock).to have_received(:send_message).with(any_args()).exactly(3)

            [707, 808, 909].each do |fake_id|
              expect(selenium_directives_mock).to have_received(:send_message).once.with(fake_id, 'fake message')
            end
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
        allow(selenium_directives_mock).to receive(:get_table_data_by_container_id).with(kind_of(String)).and_return({1 =>[]})
        allow(selenium_directives_mock).to receive(:send_message).with(kind_of(Integer), kind_of(String))

        dummy_location  = Location.new({ city: "fake city", state: :NY, zip_code: 11011 })
        sut = OpportunitiesHunter.new(selenium_directives_mock, "fake@email.com", "fake_password")
        sut.hunter_all(dummy_location, 'dummy subject')

        expect(selenium_directives_mock).to have_received(:login).once.with("fake@email.com", "fake_password")
      end
    end
  end
end
