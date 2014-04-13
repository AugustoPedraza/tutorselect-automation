require 'spec_helper'

describe OpportunitiesAnalyzer do
  describe ".add" do
    context "not opportunities loaded" do
      context 'simple subject' do
        it "add new opportunity" do
          data = { username: 'Kerry T.', user_id: '11211', subject: 'Dyslexia near 11111', date: '04/11' }
          sut = OpportunitiesAnalyzer.new
          sut.add(data)
          expect(sut.all).to eql({ dyslexia: { "11211_11111_04/11" => 1 } })
        end

        it "update opportunity counter twice" do
          data = { username: 'Kerry T.', user_id: '11211', subject: 'Dyslexia near 11111', date: '04/11' }
          sut = OpportunitiesAnalyzer.new
          sut.add(data)
          sut.add(data)

          expect(sut.all).to eql({ dyslexia: { "11211_11111_04/11" => 2 } })
        end
      end

      context "various subjects" do
        it "add two differents opportunities" do
          dyslexia_op = { username: 'Kerry T.',  user_id: '11211', subject: 'Dyslexia near 11111', date: '04/11' }
          french_op   = { username: 'August P.', user_id: '20050', subject: 'French near 99099',  date: '05/11' }
          sut = OpportunitiesAnalyzer.new
          sut.add(dyslexia_op)
          sut.add(french_op)

          expect(sut.all).to eql({
            dyslexia: { "11211_11111_04/11" => 1 },
            french:   { "20050_99099_05/11" => 1 } })
        end
      end
    end
  end
end
