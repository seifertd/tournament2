describe "Tournament2::Scorer" do
  it "needs to be implemented" do
    expect { Tournament2::Scorer.new(nil, nil).score_of(0,0,1) }.to raise_error
  end
  it "knows the names of registered scorers" do
    expect(Tournament2::Scorer.scorer_names.size).to be > 0
  end
  shared_examples "a scoring system class" do
    it "is the right type" do
      expect(scoring_class).to be < Tournament2::Scorer
    end
    it "has a name" do
      expect(scoring_class.scorer_name.length).to be > 0
    end
    it "has a description" do
      expect(scoring_class.description.length).to be > 0
    end
  end
  describe "Basic scorer" do
    let(:scoring_class) { Tournament2::BasicScorer }
    it_behaves_like "a scoring system class"
  end
  describe "Basic2 scorer" do
    let(:scoring_class) { Tournament2::BasicScorer2 }
    it_behaves_like "a scoring system class"
  end
  describe "JoshPatashnik scorer" do
    let(:scoring_class) { Tournament2::JoshPatashnikScorer }
    it_behaves_like "a scoring system class"
  end
  describe "TweakedJoshPatashnik scorer" do
    let(:scoring_class) { Tournament2::TweakedJoshPatashnikScorer }
    it_behaves_like "a scoring system class"
  end
#  describe "FFI scorer" do
#    let(:scoring_class) { Tournament2::FFIScorer }
#    it_behaves_like "a scoring system class instance"
#  end
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
describe "a bracket with no games played" do
  let(:teams) { Tournament2.ncaa_teams }
  let(:debug) { false }
  let(:bracket) { Tournament2::Bracket.new(64) }
  shared_examples "a scoring system" do
    it "score is zero with random picks" do
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
            loser = matchup_teams.max_by(&:seed)
            game_score = scorer.score_of(round, winner.index, loser.index)
            @expected_score += game_score
            #puts "Round: #{round} Game: #{game}: Winner: #{winner.inspect} Game Score: #{game_score}" if debug
            @picks.record_win_by teams.index(winner)
          end
        end
        @picks.reset_final_results
      end
      it "is complete" do
        expect(@picks.complete?).to be(true)
      end
      it "has the highest possible max score" do
        score = scorer.score(@picks)
        #puts "Score from #{scorer.class.name}: #{score.inspect}: expected: #{@expected_score}"
        expect(score.last).to eq(@expected_score)
      end
    end
  end
  describe "basic scorer" do
    let(:scorer) { Tournament2::BasicScorer.new(teams, bracket) }
    it_behaves_like "a scoring system"
  end
  describe "josh patashnik scorer" do
    let(:scorer) { Tournament2::JoshPatashnikScorer.new(teams, bracket) }
    it_behaves_like "a scoring system"
  end
  describe "tweaked josh patashnik scorer" do
    let(:scorer) { Tournament2::TweakedJoshPatashnikScorer.new(teams, bracket) }
    it_behaves_like "a scoring system"
  end
  describe "ffi basic scorer" do
    #puts "SCORER: FFI BASIC"
    let(:scorer) { Tournament2::FFIScorer.new(:basic, bracket) }
    it_behaves_like "a scoring system"
  end
  describe "ffi josh patashnick scorer" do
    #puts "SCORER: FFI JOSHP"
    let(:debug) { true }
    let(:scorer) { Tournament2::FFIScorer.new(:josh_patashnik, bracket) }
    it_behaves_like "a scoring system"
  end
  describe "ffi tweaked josh patashnick scorer" do
    #puts "SCORER: FFI TWEAKED JOSHP"
    let(:debug) { false }
    let(:scorer) { Tournament2::FFIScorer.new(:tweaked_josh_patashnik, bracket) }
    it_behaves_like "a scoring system"
  end
  describe "ffi constant value scorer" do
    #puts "SCORER: FFI CONSTANT VALUE"
    let(:debug) { false }
    let(:scorer) { Tournament2::FFIScorer.new(:constant_value, bracket) }
    it_behaves_like "a scoring system"
  end
  describe "ffi upset scorer" do
    #puts "SCORER: FFI UPSET"
    let(:debug) { false }
    let(:scorer) { Tournament2::FFIScorer.new(:upset, bracket) }
    it_behaves_like "a scoring system"
  end
  describe "ffi unknown type scorer" do
    it "should not be instantiable" do
      expect { Tournament2::FFIScorer.new(:smoochy, bracket) }.to raise_exception
    end
  end
end
