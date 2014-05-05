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
    before(:each) do
      @navigate_mock = double('navigateElement')
      allow(@navigate_mock).to receive(:to)

      @span_mock = double('spanElement')
      allow(@span_mock).to receive(:text).and_return('Hello FakeUser!')

      @element_mock = double('element')

      #Used as textbox
      allow(@element_mock).to receive(:clear)
      allow(@element_mock).to receive(:click)
      allow(@element_mock).to receive(:send_keys)

      select_item_mock = double('SelectItem')
      allow(select_item_mock).to receive(:click)
      allow(select_item_mock).to receive(:selected?).and_return(:false)

      #Used as combobox. This stub methods are required for Selenium::WebDriver::Support::Select
      allow(@element_mock).to receive(:tag_name).and_return('select')
      allow(@element_mock).to receive(:attribute).with(:multiple)
      allow(@element_mock).to receive(:find_elements).with(:xpath, an_instance_of(String)).and_return([select_item_mock])


      @driver_mock = double(Selenium::WebDriver::Driver)
      allow(@driver_mock).to receive(:navigate).and_return(@navigate_mock)
      allow(@driver_mock).to receive(:find_element).with(:class, an_instance_of(String)).and_return(@span_mock)
      allow(@driver_mock).to receive(:find_element).with(:id,    an_instance_of(String)).and_return(@element_mock)
    end

    context '.logged? is true' do
      it "navigate to profile edit url" do
        sut = SeleniumDirectives.new @driver_mock

        sut.setup_address('city', 'state', 'zip_code')
        expect(@navigate_mock).to have_received(:to).with('https://www.tutorselect.com/portal/myaccount.aspx')
      end

      it "form filled and posted" do
        sut = SeleniumDirectives.new @driver_mock

        sut.setup_address('Fake City', 'FS', '00100')

        expect(@element_mock).to have_received(:clear).twice

        expect(@element_mock).to have_received(:send_keys).with('Fake City').once
        expect(@element_mock).to have_received(:send_keys).with('00100').once

        expect(@element_mock).to have_received(:find_elements).with(:xpath, /FS/).once

        #One time for the edit button and other for submit
        expect(@element_mock).to have_received(:click).twice
      end

      it "navigate to opportunities page" do
        sut = SeleniumDirectives.new @driver_mock

        sut.setup_address('city', 'state', 'zip_code')
        expect(@navigate_mock).to have_received(:to).with('https://www.tutorselect.com/portal/opportunities.aspx')
      end
    end

    context '.logged? is false' do
      it "throw exception" do
        driver_mock = double(Selenium::WebDriver::Driver)
        allow(driver_mock).to receive(:find_element).with(:class, an_instance_of(String)).and_raise('element not found')

        sut = SeleniumDirectives.new driver_mock

        expect { sut.setup_address('city', 'state', 'zip_code') }.to raise_error('invalid login')
      end
    end
  end

  describe ".get_table_data_by_container_id" do
    context '.logged? is true' do
      context "table doens't have header row" do
        before(:each) do
          navigate_mock = double('navigateElement')
          allow(navigate_mock).to receive(:to)

          span_mock = double('spanElement')
          allow(span_mock).to receive(:text).and_return('Hello FakeUser!')

          select_item_mock = double('SelectItem')
          allow(select_item_mock).to receive(:click)
          allow(select_item_mock).to receive(:selected?).and_return(:false)

          element_mock = double('element')

          #Used as combobox. This stub methods are required for Selenium::WebDriver::Support::Select
          allow(@element_mock).to receive(:tag_name).and_return('select')
          allow(@element_mock).to receive(:attribute).with(:multiple)
          allow(@element_mock).to receive(:find_elements).with(:xpath, /5/).and_return([select_item_mock])

          @driver_mock = double(Selenium::WebDriver::Driver)
          allow(@driver_mock).to receive(:navigate).and_return(navigate_mock)
          allow(@driver_mock).to receive(:find_element).with(:class, an_instance_of(String)).and_return(span_mock)

          allow(@driver_mock).to receive(:find_element).with(:id, 'Main_ddl_oppDist').and_return(@element_mock)
          allow(@driver_mock).to receive(:find_element).with(:id, 'Main_lb_opppgNext').and_raise(Selenium::WebDriver::Error::NoSuchElementError)
        end

        it "select distance of 5 miles" do
          allow(@driver_mock).to receive(:find_elements).with(:xpath, "//div[@id='id-main-table']/table/tbody/tr").and_return([])

          sut = SeleniumDirectives.new @driver_mock
          sut.get_table_data_by_container_id('id-main-table')

          expect(@driver_mock).to have_received(:find_element).with(:id, 'Main_ddl_oppDist').once
          expect(@element_mock).to have_received(:find_elements).with(:xpath, ".//option[@value = \"5\"]")
        end

        context 'area request have just one page' do
          it "get array of requests" do
            table_rows_mock = []

            3.times do |i|
              i = i + 1
              table_data_mock = []

              username_link_mock = double("aElement#{i}")
              allow(username_link_mock).to receive(:attribute).with('href').and_return("http://fakes/username#{i}")

              td_username_mock = double("tdUserElement#{i}")
              allow(td_username_mock).to receive(:text).and_return("fake username#{i}")
              allow(td_username_mock).to receive(:find_element).with(:tag_name, 'a').and_return(username_link_mock)

              td_subject_mock = double("tdSubjectElement#{i}")
              allow(td_subject_mock).to receive(:text).and_return("fake subject#{i}")

              td_date_mock = double("tdDateElement#{i}")
              allow(td_date_mock).to receive(:text).and_return("fake date#{i}")

              table_data_mock << td_username_mock << td_subject_mock << td_date_mock

              tr_mock = double("trElement#{i}")
              allow(tr_mock).to receive(:find_elements).with(:tag_name, 'td').and_return(table_data_mock)

              table_rows_mock << tr_mock
            end

            allow(@driver_mock).to receive(:find_elements).with(:xpath, "//div[@id='id-main-table']/table/tbody/tr").and_return(table_rows_mock)

            sut = SeleniumDirectives.new @driver_mock

            actual = sut.get_table_data_by_container_id('id-main-table')

            expect(actual).to eql({ 1 =>
              [{ username: 'fake username1', request_id: 'http://fakes/username1', subject:  'fake subject1', date: 'fake date1' },
              { username: 'fake username2', request_id: 'http://fakes/username2', subject:  'fake subject2', date: 'fake date2' },
              { username: 'fake username3', request_id: 'http://fakes/username3', subject:  'fake subject3', date: 'fake date3' }
              ]})
          end
        end

        context 'area request have three' do
          it "navigate every page" do
            driver_mock = double(Selenium::WebDriver::Driver)
            allow(driver_mock).to receive(:navigate).and_return(@navigate_mock)

            page_number = 1

            next_page_link_mock = double('linkElement')
            allow(next_page_link_mock).to receive(:click)

            allow(driver_mock).to receive(:find_element) do |type, value|
              return_value = nil

              return_value = @span_mock    if type == :class
              return_value = @element_mock if type == :id and value == 'Main_ddl_oppDist'

              if type == :id and value == 'Main_lb_opppgNext'
                raise Selenium::WebDriver::Error::NoSuchElementError if page_number > 3
                return_value =  next_page_link_mock
                page_number = page_number + 1
              end

              return_value
            end

            allow(driver_mock).to receive(:find_elements).with(:xpath, "//div[@id='id-main-table']/table/tbody/tr").and_return([])

            sut = SeleniumDirectives.new driver_mock

            actual = sut.get_table_data_by_container_id('id-main-table')

            expect(next_page_link_mock).to have_received(:click).exactly(3)
          end
        end
      end
    end
  end

  describe ".send_message" do
    context "valid request id" do
      it "send a tutorselect message" do
        navigate_mock = double('navigateElement')
        allow(navigate_mock).to receive(:to).ordered

        text_box_mock = double('textBoxElement')
        allow(text_box_mock).to receive(:clear).ordered
        allow(text_box_mock).to receive(:send_keys).ordered

        link_button_mock = double('aElement')
        allow(link_button_mock).to receive(:click).ordered

        label_mock = double('lblElement')
        allow(label_mock).to receive(:text).and_return('Your message was sent!')

        driver_mock = double(Selenium::WebDriver::Driver)
        allow(driver_mock).to receive(:navigate).and_return(navigate_mock)
        allow(driver_mock).to receive(:find_element).with(:id, 'Main_tbMSG').and_return(text_box_mock)
        allow(driver_mock).to receive(:find_element).with(:id, 'Main_bs').and_return(link_button_mock)
        allow(driver_mock).to receive(:find_element).with(:id, 'Main_lbl_msgError').and_return(label_mock)

        sut = SeleniumDirectives.new driver_mock

        sut.send_message(77077, 'fake message')

        expect(navigate_mock).to have_received(:to).once.with("https://www.tutorselect.com/portal/viewcprofile.aspx?trid=77077")
        expect(text_box_mock).to have_received(:clear).once
        expect(text_box_mock).to have_received(:send_keys).once.with('fake message')
        expect(link_button_mock).to have_received(:click).once
      end

      context "message send successful" do
        it "return true" do
          navigate_mock = double('navigateElement')
          allow(navigate_mock).to receive(:to).ordered

          text_box_mock = double('textBoxElement')
          allow(text_box_mock).to receive(:clear).ordered
          allow(text_box_mock).to receive(:send_keys).ordered

          link_button_mock = double('aElement')
          allow(link_button_mock).to receive(:click).ordered

          span_mock = double('spanElement')
          allow(span_mock).to receive(:text).and_return('Your message was sent!')

          driver_mock = double(Selenium::WebDriver::Driver)
          allow(driver_mock).to receive(:navigate).and_return(navigate_mock)
          allow(driver_mock).to receive(:find_element).with(:id, 'Main_tbMSG').and_return(text_box_mock)
          allow(driver_mock).to receive(:find_element).with(:id, 'Main_bs').and_return(link_button_mock)
          allow(driver_mock).to receive(:find_element).with(:id, 'Main_lbl_msgError').and_return(span_mock).ordered

          sut = SeleniumDirectives.new driver_mock

          expect(sut.send_message(77077, 'fake message')).to be_true
          expect(navigate_mock).to have_received(:to).once.with("https://www.tutorselect.com/portal/viewcprofile.aspx?trid=77077")
          expect(text_box_mock).to have_received(:clear).once
          expect(text_box_mock).to have_received(:send_keys).once.with('fake message')
          expect(link_button_mock).to have_received(:click).once
          expect(span_mock).to have_received(:text).once
        end
      end

      context "message doenst send" do
        it "raise a error with the receive message" do
          navigate_mock = double('navigateElement')
          allow(navigate_mock).to receive(:to).ordered

          text_box_mock = double('textBoxElement')
          allow(text_box_mock).to receive(:clear).ordered
          allow(text_box_mock).to receive(:send_keys).ordered

          link_button_mock = double('aElement')
          allow(link_button_mock).to receive(:click).ordered

          span_mock = double('spanElement')
          allow(span_mock).to receive(:text).and_return('Some error message')

          driver_mock = double(Selenium::WebDriver::Driver)
          allow(driver_mock).to receive(:navigate).and_return(navigate_mock)
          allow(driver_mock).to receive(:find_element).with(:id, 'Main_tbMSG').and_return(text_box_mock)
          allow(driver_mock).to receive(:find_element).with(:id, 'Main_bs').and_return(link_button_mock)
          allow(driver_mock).to receive(:find_element).with(:id, 'Main_lbl_msgError').and_return(span_mock).ordered

          sut = SeleniumDirectives.new driver_mock

          expect(lambda{ sut.send_message(77077, 'fake message') }).to raise_error('Some error message')
        end
      end
    end
  end
end
