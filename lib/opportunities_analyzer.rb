class OpportunitiesAnalyzer
  @@opportunities = {}

  def self.add(data)
    data[:subject].slice!(/\s+near\s+/)
    key      = data[:subject].gsub(/\s+/, '_').gsub(/\d{5}/, '').downcase
    zip_code = data[:subject].scan(/\d{5}/).first

    opportunity_id = "%s_%s_%s" % [data[:user_id], zip_code, data[:date]]
    @@opportunities[key.to_sym] = {opportunity_id => 1}
  end

  def self.all
    @@opportunities
  end
end
