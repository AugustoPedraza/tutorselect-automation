class OpportunitiesAnalyzer

  def initialize
    @grouped_subjects = {}
  end

  def add(data)
    data[:subject].slice!(/\s+near\s+/)
    subject_id      = data[:subject].gsub(/\s+/, '_').gsub(/\d{5}/, '').downcase.to_sym
    zip_code        = data[:subject].scan(/\d{5}/).first
    opportunity_id  = "%s_%s_%s" % [data[:user_id], zip_code, data[:date]]

    if @grouped_subjects.include? subject_id
      grouped_opportunities = @grouped_subjects[subject_id]

      if grouped_opportunities.include? opportunity_id
        grouped_opportunities[opportunity_id] = grouped_opportunities[opportunity_id] + 1
      else
        grouped_opportunities[opportunity_id] = 1
      end
    else
      @grouped_subjects[subject_id] = { opportunity_id => 1 }
    end
  end

  def all
    @grouped_subjects
  end
end
