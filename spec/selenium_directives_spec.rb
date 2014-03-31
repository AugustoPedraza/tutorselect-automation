require 'spec_helper'

describe SeleniumDirectives do
  describe ".login" do
    context 'when user and pass are valid' do
      it "welcome_message is setup" do
        navigate_stub = double('navigate')

        clickeable_el_mock = double('element')
        allow(clickeable_el_mock).to receive(:send_keys)
        allow(clickeable_el_mock).to receive(:click)

        text_mock = double('spanElement')
        text_mock.stub(:text).and_return('Hello FakeUser!')

        driver_mock = double(Selenium::WebDriver::Driver)
        driver_mock.stub(:navigate){ navigate_stub }
        driver_mock.stub(:find_element).with(:class, an_instance_of(String) ).and_return(text_mock)
        driver_mock.stub(:find_element).with(:id, an_instance_of(String) ).and_return(clickeable_el_mock)

        sut = SeleniumDirectives.new driver_mock

        navigate_stub.should_receive(:to).with("https://www.tutorselect.com/login")

        clickeable_el_mock.should_receive(:send_keys).with('fake_email@rspec.com').once
        clickeable_el_mock.should_receive(:send_keys).with('fake_pass123').once
        clickeable_el_mock.stub(:send_keys)

        sut.login('fake_email@rspec.com', 'fake_pass123')
        expect(sut.welcome_message).to eq('Hello FakeUser!')
      end
    end
  end
end
