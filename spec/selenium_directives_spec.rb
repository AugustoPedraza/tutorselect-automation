require 'spec_helper'

describe SeleniumDirectives do
  describe ".login" do
    context 'when user and pass are valid' do
      it "success login" do
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

        expect(sut.login('fake_email@rspec.com', 'fake_pass123')).to eq(true)
      end
    end
  end

  describe ".setup_address" do
    context '.logged? is true' do
      it "navigate to profile edit url" do
        navigate_mock = double('navigate')
        allow(navigate_mock).to receive(:to)

        text_mock = double('spanElement')
        allow(text_mock).to receive(:text).and_return('Hello FakeUser!')

        driver_mock = double(Selenium::WebDriver::Driver)
        allow(driver_mock).to receive(:find_element).with(:class, an_instance_of(String)).and_return(text_mock)
        allow(driver_mock).to receive(:navigate).and_return(navigate_mock)

        sut = SeleniumDirectives.new driver_mock

        sut.setup_address('city', 'state', 'zip_code')
        expect(navigate_mock).to have_received(:to).with('https://www.tutorselect.com/portal/myaccount.aspx')
      end
    end
  end
end
