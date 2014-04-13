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
      end
    end

    context 'same opportunity loaded twice' do
      it "update opportunity counter" do
        data = { username: 'Kerry T.', user_id: '11211', subject: 'Dyslexia near 11111', date: '04/11' }
        sut = OpportunitiesAnalyzer.new
        sut.add(data)
        sut.add(data)

        expect(sut.all).to eql({ dyslexia: { "11211_11111_04/11" => 2 } })
      end
    end
  end
end
