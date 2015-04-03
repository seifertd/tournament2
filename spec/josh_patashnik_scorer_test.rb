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
