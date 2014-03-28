require 'spec_helper'

describe ZipCodesReader do
  describe ".foreach" do
    context 'when file have expected format' do
      before(:each) do
        CSV.open("fake_zip_codes.csv", "w") do |csv|

          #header
          csv << ['zip', 'primary_city', 'state']

          csv << ['0001', 'fake city 1', 'S1']
          csv << ['0002', 'fake city 2', 'S2']
          csv << ['0003', 'fake city 3', 'S3']
          csv << ['0004', 'fake city 4', 'S4']
        end
      end

      after(:each) do
        File.delete('fake_zip_codes.csv')
      end

      specify do
        expect { |b| ZipCodesReader.foreach('fake_zip_codes.csv', &b) }
          .to yield_control.exactly(4).times
      end
    end
  end
end
