require 'csv'

class ZipCodesReader
  def self.foreach(file_path)
    mapping_keys = { 'zip' => :zip, 'primary_city' => :city, 'state' => :state }

    CSV.foreach(file_path, headers: true) do |csv_row|
      new_row = csv_row.inject({}) { |new_h, (k,v)| new_h[mapping_keys[k]] = v; new_h }
      yield new_row
    end
  end
end
