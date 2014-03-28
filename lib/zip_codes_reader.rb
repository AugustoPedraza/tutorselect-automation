require 'fastercsv'

class ZipCodesReader
  def self.foreach(file_path)
    counter = 0
    IO.foreach(file_path) do |line|
      if counter == 0
        counter = 1
        next
      end
      yield line
    end
  end
end

# place[:zip_code]
# place[:city]
# place[:state]