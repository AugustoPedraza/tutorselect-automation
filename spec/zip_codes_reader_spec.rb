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
          csv << ['0005', 'fake city 5', 'S5']
        end
      end

      after(:each) do
        File.delete('fake_zip_codes.csv')
      end

      specify do
        expect { |b| ZipCodesReader.foreach('fake_zip_codes.csv', &b) }
          .to yield_control.exactly(5).times
      end

      specify do
        expect { |b| ZipCodesReader.foreach('fake_zip_codes.csv', &b) }
          .to yield_successive_args(
            { zip: '0001', city: 'fake city 1', state: 'S1' },
            { zip: '0002', city: 'fake city 2', state: 'S2' },
            { zip: '0003', city: 'fake city 3', state: 'S3' },
            { zip: '0004', city: 'fake city 4', state: 'S4' },
            { zip: '0005', city: 'fake city 5', state: 'S5' })
      end
    end
  end
end
