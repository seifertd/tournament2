describe "Tournament2::Scorer" do
  it "needs to be implemented" do
    expect { Tournament2::Scorer.new(nil, nil).score_of(0,0,1) }.to raise_error
  end
  it "knows the names of registered scorers" do
    expect(Tournament2::Scorer.scorer_names.size).to be > 0
  end
  shared_examples "a scoring system class instance" do
    let(:instance) { scoring_class.new(nil,nil) }
    it "can be constructed" do
      expect(instance).to be_instance_of(scoring_class)
    end
    it "has a name" do
      expect(instance.name.length).to be > 0
    end
    it "has a description" do
      expect(instance.description.length).to be > 0
    end
  end
  describe "Basic scorer" do
    let(:scoring_class) { Tournament2::BasicScorer }
    it_behaves_like "a scoring system class instance"
  end
  describe "Basic2 scorer" do
    let(:scoring_class) { Tournament2::BasicScorer2 }
    it_behaves_like "a scoring system class instance"
  end
  describe "JoshPatashnik scorer" do
    let(:scoring_class) { Tournament2::JoshPatashnikScorer }
    it_behaves_like "a scoring system class instance"
  end
  describe "TweakedJoshPatashnik scorer" do
    let(:scoring_class) { Tournament2::TweakedJoshPatashnikScorer }
    it_behaves_like "a scoring system class instance"
  end
end
describe "Tournament2::BasicScorer" do
  describe "with a complete bracket" do
    before do
      @teams = (0..63).to_a.map {|n| "t#{n}".to_sym}
      @bracket = Tournament2::Bracket.random_bracket(@teams)
      @scorer = Tournament2::Scorer.scorer_by_name('Basic', @teams, @bracket)
      @scorer2 = Tournament2::Scorer.scorer_by_name('Basic2', @teams, @bracket)
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
describe "Tournament2 scoring system" do
  SEEDS = [1,16,8,9,5,12,4,13,6,11,3,14,7,10,2,15]
  let(:teams) { (0..63).to_a.map{|n| Tournament2::Team.new("Team#{n}", "t#{n}", SEEDS[n % 16], n)} }
  shared_examples "a scoring system" do
    describe "with no games played" do
      let(:bracket) { Tournament2::Bracket.new(64) }
      it "scores zero with random picks" do
        picks = Tournament2::Bracket.random_bracket(teams)
        expect(scorer.score(picks).first).to eq(0)
      end
      describe "picks of all favorites" do
        before do
          @expected_score = 0
          @picks = Tournament2::Bracket.new(64)
          0.upto(@picks.rounds-1) do |round|
            0.upto(@picks.games_in_round(round)-1) do |game|
              matchup = @picks.matchup(round,game)
              matchup_teams = matchup.map{|i| teams[i]}
              winner = matchup_teams.min_by(&:seed)
              @expected_score += scorer.score_of(round, winner.index, nil) 
              #puts "Round: #{round} Game: #{game}: Matchup: #{teams.inspect} Winner: #{winner.inspect}"
              @picks.record_win_by teams.index(winner)
            end
          end
        end
        it "has the highest possible max score" do
          expect(scorer.score(@picks).last).to eq(@expected_score)
        end
      end
    end
  end
  describe "josh patashnik scorer" do
    let(:scorer) { Tournament2::JoshPatashnikScorer.new(teams, bracket) }
    it_behaves_like "a scoring system"
  end
  describe "tweaked josh patashnik scorer" do
    let(:scorer) { Tournament2::TweakedJoshPatashnikScorer.new(teams, bracket) }
    it_behaves_like "a scoring system"
  end
end
