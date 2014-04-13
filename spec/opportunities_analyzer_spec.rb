require 'spec_helper'

describe OpportunitiesAnalyzer do
  describe ".add" do
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

      it "add five opportunities with three differents of same subject and two repeated " do
        spanish_op  = { username: 'August P.', user_id: '20050', subject: 'Spanish near 99099',  date: '05/11' }
        math_op_1   = { username: 'Kerry T.',  user_id: '11211', subject: 'Math near 99099', date: '01/11' }
        math_op_2   = { username: 'Josh J.',  user_id: '33444', subject: 'Math near 22330', date: '03/14' }
        math_op_3   = { username: 'Alfred G.',  user_id: '30003', subject: 'Math near 11111', date: '04/11' }

        sut = OpportunitiesAnalyzer.new
        sut.add(spanish_op)
        sut.add(math_op_1)
        sut.add(math_op_2)
        sut.add(math_op_3)
        sut.add(spanish_op)


        expect(sut.all).to eql({
          spanish: { "20050_99099_05/11" => 2 },
          math:   { "11211_99099_01/11" => 1, "33444_22330_03/14" => 1, "30003_11111_04/11" => 1 } })
      end
    end
  end
end
