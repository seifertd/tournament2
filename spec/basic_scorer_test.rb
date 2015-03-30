require 'basic_scorer'
require 'bracket'

describe BasicScorer do
  before do
    @teams = (0..63).to_a.map {|n| "t#{n}".to_sym}
    @bracket = Bracket.random_bracket(@teams)
    @scorer = BasicScorer.new(@teams, @bracket)
  end
  it "scores perfectly a perfect pick" do
    expect(@scorer.score(@bracket)).to eq([192,192])
  end
end
