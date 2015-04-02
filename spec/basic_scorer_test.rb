describe "Tournament2::Scorer" do
  it "needs to be implemented" do
    expect { Tournament2::Scorer.new(nil, nil).score_of(0,0,1) }.to raise_error
  end
end
describe "Tournament2::BasicScorer" do
  describe "with a complete bracket" do
    before do
      @teams = (0..63).to_a.map {|n| "t#{n}".to_sym}
      @bracket = Tournament2::Bracket.random_bracket(@teams)
      @scorer = Tournament2::BasicScorer.new(@teams, @bracket)
      @scorer2 = Tournament2::BasicScorer2.new(@teams, @bracket)
    end
    it "is complete" do
      expect(@bracket.complete?).to be(true)
    end
    it "scores perfectly a perfect pick" do
      expect(@scorer.score(@bracket)).to eq([192,192])
    end
    it "scores 2 perfectly a perfect pick" do
      expect(@scorer2.score(@bracket)).to eq([192,192])
    end
    describe "with a random pick" do
      before do
        @picks = Tournament2::Bracket.random_bracket(@teams)
      end
      it "calculates a score" do
        expect(@scorer2.score(@picks)).to eq(@scorer.score(@picks))
      end
    end
  end
end
