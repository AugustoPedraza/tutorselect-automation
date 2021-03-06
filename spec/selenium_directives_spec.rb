require 'spec_helper'

describe SeleniumDirectives do
  describe ".login" do
    context 'when user and pass are valid' do
      before(:each) do
        text_mock = double('spanElement')
        allow(text_mock).to receive(:text).and_return('Hello FakeUser!')

        @driver_mock = double(Selenium::WebDriver::Driver)
        allow(@driver_mock).to receive(:navigate){ navigate_stub }
        allow(@driver_mock).to receive(:find_element).with(:class, an_instance_of(String) ).and_return(text_mock)
        allow(@driver_mock).to receive(:find_element).with(:id, an_instance_of(String) ).and_return(clickeable_el_mock)
      end

      let(:navigate_stub) { double('navigateElement') }

      let(:clickeable_el_mock) do
        mock = double('clickeableElement')
        allow(mock).to receive(:send_keys)
        allow(mock).to receive(:click)

        mock
      end

      subject { SeleniumDirectives.new @driver_mock }

      it "success login" do
        expect(navigate_stub).to receive(:to).with("https://www.tutorselect.com/login")

        expect(clickeable_el_mock).to receive(:send_keys).with('fake_email@rspec.com').once
        expect(clickeable_el_mock).to receive(:send_keys).with('fake_pass123').once

        expect(subject.login('fake_email@rspec.com', 'fake_pass123')).to eq(true)
      end
    end
  end

  describe ".setup_address" do
    context '.logged? is true' do
      before(:each) do
        @driver_mock = double(Selenium::WebDriver::Driver)
        allow(@driver_mock).to receive(:navigate).and_return(navigate_mock)
        allow(@driver_mock).to receive(:find_element).with(:class, an_instance_of(String)).and_return(span_mock)
        allow(@driver_mock).to receive(:find_element).with(:id,    an_instance_of(String)).and_return(generic_element_mock)
      end

      let(:navigate_mock) do
        mock = double('navigateElement')
        allow(mock).to receive(:to)

        mock
      end

      let(:span_mock) do
        mock = double('spanElement')
        allow(mock).to receive(:text).and_return('Hello FakeUser!')

        mock
      end

      let(:generic_element_mock) do
        mock = double('element')

        #Used as textbox
        allow(mock).to receive(:clear)
        allow(mock).to receive(:click)
        allow(mock).to receive(:send_keys)

        select_item_mock = double('SelectItem')
        allow(select_item_mock).to receive(:click)
        allow(select_item_mock).to receive(:selected?).and_return(:false)

        #Used as combobox. This stub methods are required for Selenium::WebDriver::Support::Select
        allow(mock).to receive(:tag_name).and_return('select')
        allow(mock).to receive(:attribute).with(:multiple)
        allow(mock).to receive(:find_elements).with(:xpath, an_instance_of(String)).and_return([select_item_mock])

        mock
      end

      subject { SeleniumDirectives.new @driver_mock }

      it "navigate to profile edit url" do
        subject.setup_address('city', 'state', 'zip_code')
        expect(navigate_mock).to have_received(:to).with('https://www.tutorselect.com/portal/myaccount.aspx')
      end

      it "form filled and posted" do
        subject.setup_address('Fake City', 'FS', '00100')

        expect(generic_element_mock).to have_received(:clear).twice

        expect(generic_element_mock).to have_received(:send_keys).with('Fake City').once
        expect(generic_element_mock).to have_received(:send_keys).with('00100').once

        expect(generic_element_mock).to have_received(:find_elements).with(:xpath, /FS/).once

        #One time for the edit button and other for submit
        expect(generic_element_mock).to have_received(:click).twice
      end

      it "navigate to opportunities page" do
        subject.setup_address('city', 'state', 'zip_code')
        expect(navigate_mock).to have_received(:to).with('https://www.tutorselect.com/portal/opportunities.aspx')
      end
    end

    context '.logged? is false' do
      let(:driver_mock) do
        mock = double(Selenium::WebDriver::Driver)
        allow(mock).to receive(:find_element).with(:class, an_instance_of(String)).and_raise('element not found')

        mock
      end

      subject { SeleniumDirectives.new driver_mock }

      it "throw exception" do
        expect { subject.setup_address('city', 'state', 'zip_code') }.to raise_error('invalid login')
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

        subject { SeleniumDirectives.new @driver_mock }

        it "select distance of 50 miles" do
          allow(@driver_mock).to receive(:find_elements)
            .with(:xpath, "//div[@id='id-main-table']/table/tbody/tr")
            .and_return([])

          subject.get_table_data_by_container_id('id-main-table')

          expect(@driver_mock).to have_received(:find_element).with(:id, 'Main_ddl_oppDist').once
          expect(@element_mock).to have_received(:find_elements).with(:xpath, ".//option[@value = \"50\"]")
        end

        context 'area request have just one page' do
          before(:each) do
            allow(@driver_mock).to receive(:find_elements)
              .with(:xpath, "//div[@id='id-main-table']/table/tbody/tr")
              .and_return(table_data_fakes)
          end

          let(:table_data_fakes) do
            (1..3).to_a.map do |i|
              tds_data = []

              username_link_mock = double("aElement#{i}")
              allow(username_link_mock).to receive(:attribute).with('href').and_return("http://fakes/username#{i}")

              td_username_mock = double("tdUserElement#{i}")
              allow(td_username_mock).to receive(:text).and_return("fake username#{i}")
              allow(td_username_mock).to receive(:find_element).with(:tag_name, 'a').and_return(username_link_mock)

              td_subject_mock = double("tdSubjectElement#{i}")
              allow(td_subject_mock).to receive(:text).and_return("fake subject#{i}")

              td_date_mock = double("tdDateElement#{i}")
              allow(td_date_mock).to receive(:text).and_return("fake date#{i}")

              tds_data << td_username_mock << td_subject_mock << td_date_mock

              tr_mock = double("trElement#{i}")
              allow(tr_mock).to receive(:find_elements).with(:tag_name, 'td').and_return(tds_data)

              tr_mock
            end
          end

          it "get array of requests" do
            actual = subject.get_table_data_by_container_id('id-main-table')

            expect(actual).to eql({ 1 =>
              [{ username: 'fake username1', request_id: 'http://fakes/username1', subject:  'fake subject1', date: 'fake date1' },
              { username: 'fake username2', request_id: 'http://fakes/username2', subject:  'fake subject2', date: 'fake date2' },
              { username: 'fake username3', request_id: 'http://fakes/username3', subject:  'fake subject3', date: 'fake date3' }
              ]})
          end
        end

        context 'area request have three page' do
          let(:next_page_link_mock) do
            mock = double('linkElement')
            allow(mock).to receive(:click)

            mock
          end

          before(:each) do
            page_number = 1

            #Simulate the behaviour of navigation,
            #throwing a exception when it doens't have other page to navitate
            allow(@driver_mock).to receive(:find_element) do |type, value|

              if type == :class
                return_value = @span_mock
              elsif type == :id and value == 'Main_ddl_oppDist'
                return_value = @element_mock
              elsif type == :id and value == 'Main_lb_opppgNext'
                raise Selenium::WebDriver::Error::NoSuchElementError if page_number > 3
                return_value =  next_page_link_mock
                page_number = page_number + 1
              else
                return_value = nil
              end

              return_value
            end

           allow(@driver_mock).to receive(:find_elements)
            .with(:xpath, "//div[@id='id-main-table']/table/tbody/tr")
            .and_return([])
          end

          it "navigate every page" do
            actual = subject.get_table_data_by_container_id('id-main-table')

            expect(next_page_link_mock).to have_received(:click).exactly(3)
          end
        end
      end
    end
  end

  describe ".send_message" do
    context "valid request id" do
      before(:each) do
        @driver_mock = double(Selenium::WebDriver::Driver)
        allow(@driver_mock).to receive(:navigate).and_return(navigate_mock)
        allow(@driver_mock).to receive(:find_element).with(:id, 'Main_tbMSG').and_return(text_box_mock)
        allow(@driver_mock).to receive(:find_element).with(:id, 'Main_bs').and_return(link_button_mock)
        allow(@driver_mock).to receive(:find_element).with(:id, 'Main_lbl_msgError').and_return(span_mock)
        allow(@driver_mock).to receive(:save_screenshot)
      end

      let(:navigate_mock) do
        mock = double('navigateElement')
        allow(mock).to receive(:to).ordered

        mock
      end

      let(:text_box_mock) do
        mock = double('textBoxElement')
        allow(mock).to receive(:clear).ordered
        allow(mock).to receive(:send_keys).ordered

        mock
      end

      let(:link_button_mock) do
        mock = double('aElement')
        allow(mock).to receive(:click).ordered

        mock
      end

      let(:span_mock) do
        mock = double('spanElement')
        allow(mock).to receive(:text).and_return('Your message was sent!').ordered

        mock
      end

      subject { SeleniumDirectives.new @driver_mock }

      it "send a tutorselect message" do
        subject.send_message(77077, 'fake message')

        expect(navigate_mock).to have_received(:to)
          .once
          .with("https://www.tutorselect.com/portal/viewcprofile.aspx?trid=77077")

        expect(text_box_mock).to have_received(:clear).once
        expect(text_box_mock).to have_received(:send_keys).once.with('fake message')
        expect(link_button_mock).to have_received(:click).once
      end

      context "message send successful" do
        it "return true" do
          expect(subject.send_message(77077, 'fake message')).to be_true
          expect(navigate_mock).to have_received(:to)
            .once
            .with("https://www.tutorselect.com/portal/viewcprofile.aspx?trid=77077")

          expect(text_box_mock).to have_received(:clear).once
          expect(text_box_mock).to have_received(:send_keys).once.with('fake message')
          expect(link_button_mock).to have_received(:click).once
          expect(span_mock).to have_received(:text).once
        end
      end

      context "message doesn't send" do
        let(:span_mock) do
          mock = double('spanElement')
          allow(mock).to receive(:text).and_return('Some error message').ordered

          mock
        end

        it "raise a error with the receive message" do
          expect(lambda{ subject.send_message(77077, 'fake message') }).to raise_error('Some error message')
        end
      end
    end
  end
end
