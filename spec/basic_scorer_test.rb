require 'basic_scorer'
require 'basic_scorer2'
require 'bracket'

describe BasicScorer do
  before do
    @teams = (0..63).to_a.map {|n| "t#{n}".to_sym}
    @bracket = Bracket.random_bracket(@teams)
    @scorer = BasicScorer.new(@teams, @bracket)
    @scorer2 = BasicScorer2.new(@teams, @bracket)
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
end
