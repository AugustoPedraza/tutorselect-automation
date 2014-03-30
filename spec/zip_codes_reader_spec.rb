require 'spec_helper'

describe ZipCodesReader do
  describe ".foreach" do
    before(:all) do
      @small_file_path = "fake_zip_codes.csv"
      CSV.open(@small_file_path, "w") do |csv|

        csv << ['zip', 'primary_city', 'state']

        csv << ['0001', 'fake city 1', 'S1']
        csv << ['0002', 'fake city 2', 'S2']
        csv << ['0003', 'fake city 3', 'S3']
        csv << ['0004', 'fake city 4', 'S4']
        csv << ['0005', 'fake city 5', 'S5']
      end
    end

    after(:all) do
      File.delete(@small_file_path)
    end

    context 'when file have expected format' do

      specify do
        expect { |b| ZipCodesReader.foreach(@small_file_path, &b) }
          .to yield_control.exactly(5).times
      end

      specify do
        expect { |b| ZipCodesReader.foreach(@small_file_path, &b) }
          .to yield_successive_args(
            { zip: '0001', city: 'fake city 1', state: 'S1' },
            { zip: '0002', city: 'fake city 2', state: 'S2' },
            { zip: '0003', city: 'fake city 3', state: 'S3' },
            { zip: '0004', city: 'fake city 4', state: 'S4' },
            { zip: '0005', city: 'fake city 5', state: 'S5' })
      end
    end

    context 'when the file is big' do
      before(:all) do
        @big_file_path = "big_fake_zip_codes.csv"

        CSV.open(@big_file_path, "w") do |csv|

          csv << ['zip', 'primary_city', 'state', 'dummy1', 'dummy2']

          500_000.times do |x|
            csv << ["#{x}".rjust(5, '0'), "fake city #{x}", "S#{rand(1..9)}", "dummy1", 'dummy2']
          end
        end

      end

      after(:all) do
        File.delete('big_fake_zip_codes.csv')
      end

      it "response time is worthless" do
        counter = 0.0
        tms_small_file = Benchmark.measure do
          ZipCodesReader.foreach(@small_file_path) { |z| counter = counter + 1 }
        end

        small_file_average = tms_small_file.total.fdiv(counter)

        counter = 0.0
        tms_big_file = Benchmark.measure do
          ZipCodesReader.foreach(@big_file_path) { |z| counter = counter + 1 }
        end

        big_file_average = tms_big_file.total.fdiv(counter)

        expect(big_file_average - small_file_average).to be < 0.0001
      end
    end
  end
end
