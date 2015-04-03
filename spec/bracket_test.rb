describe "Tournament2::Bracket" do
  before do
    @bracket = Tournament2::Bracket.new(64)
  end
  it "calculates number of rounds" do
    expect(@bracket.rounds).to eq(6)
    expect(Tournament2::Bracket.new(16).rounds).to eq(4)
  end
  it "knows first round matchups" do
    expect(@bracket.matchup(0,0)).to eq([0,1])
    expect(@bracket.matchup(0,31)).to eq([62,63])
  end
  it "doesn't know matchup for games where previous games are not played" do
    expect(@bracket.matchup(1,0)).to be(nil)
  end
  it "calculates number of games per round" do
    expect(@bracket.games_in_round(0)).to eq(32)
    expect(@bracket.games_in_round(1)).to eq(16)
    expect(@bracket.games_in_round(2)).to eq(8)
    expect(@bracket.games_in_round(3)).to eq(4)
    expect(@bracket.games_in_round(4)).to eq(2)
    expect(@bracket.games_in_round(5)).to eq(1)
  end
  it "determines result offset" do
    expect(@bracket.result_offset(0,0)).to eq(0)
    expect(@bracket.result_offset(0,31)).to eq(31)
    expect(@bracket.result_offset(1,0)).to eq(32)
    expect(@bracket.result_offset(1,15)).to eq(47)
    expect(@bracket.result_offset(2,0)).to eq(48)
    expect(@bracket.result_offset(2,7)).to eq(55)
    expect(@bracket.result_offset(3,0)).to eq(56)
    expect(@bracket.result_offset(3,3)).to eq(59)
    expect(@bracket.result_offset(4,0)).to eq(60)
    expect(@bracket.result_offset(4,1)).to eq(61)
    expect(@bracket.result_offset(5,0)).to eq(62)
  end
  describe "that is not complete" do
    before do
      @bracket = Tournament2::Bracket.new(64)
      @bracket.results = 0b001010110101010 
      @bracket.played  = 0b111111111111111 
      @bracket.round = 0
    end
    it "says so" do
      expect(@bracket.complete?).to be(false)
    end
    it "has no winner" do
      expect(@bracket.winner).to be_falsy
    end
    it "knows round 1 matchups" do
      expect(@bracket.matchup(1,0)).to eq([0,3])
      expect(@bracket.matchup(1,4)).to eq([17,18])
    end
    it "knows a team that has won is alive" do
      expect(@bracket.team_alive(0)).to be(true)
    end
    it "knows a team that has lost is not alive" do
      expect(@bracket.team_alive(1)).to be(false)
    end
    it "knows a team that has not played is alive" do
      expect(@bracket.team_alive(60)).to be(true)
    end
    it "knows number of completed games" do
      expect(@bracket.games_played).to eq(15)
    end
    it "records first match winner and loser" do
      result = @bracket.result(0,0)
      expect(result[1]).to eq(0)
      expect(result[2]).to eq(1)
    end
    it "returns nil as result for unplayed games" do
      expect(@bracket.result(0,30)).to be(nil)
    end
    it "raises an error if a win is recorded by a team that has lost" do
      expect { @bracket.record_win_by(1) }.to raise_error
    end
    it "can be printed" do
      out = StringIO.new("")
      @bracket.print(out)
      expect(out.string).to match(/RESULTS: 0+1010110101010/)
    end
  end
  describe "that is complete" do
    before do
      @bracket = Tournament2::Bracket.new(16)
      @bracket.results = 0b001010110101010 
      @bracket.played  = 0b111111111111111 
      @bracket.round = 4
    end
    it "says so" do
      expect(@bracket.complete?).to be(true)
    end
    it "raises an error if a win is recorded" do
      expect { @bracket.record_win_by(@bracket.winner) }.to raise_error
    end
    it "has a winner" do
      expect(@bracket.winner).to eq(4)
    end
    it "gets first round results" do
      expect(@bracket.result(0,0)).to eq([0,0,1])
      expect(@bracket.result(0,1)).to eq([1,3,2])
      expect(@bracket.result(0,2)).to eq([0,4,5])
      expect(@bracket.result(0,3)).to eq([1,7,6])
      expect(@bracket.result(0,4)).to eq([0,8,9])
      expect(@bracket.result(0,5)).to eq([1,11,10])
      expect(@bracket.result(0,6)).to eq([0,12,13])
      expect(@bracket.result(0,7)).to eq([1,15,14])
    end
    it "gets second round results" do
      expect(@bracket.result(1,0)).to eq([0b11,3,0])
      expect(@bracket.result(1,1)).to eq([0b00,4,7])
      expect(@bracket.result(1,2)).to eq([0b11,11,8])
      expect(@bracket.result(1,3)).to eq([0b00,12,15])
    end
    it "gets third round results" do
      expect(@bracket.result(2,0)).to eq([0b100,4,3])
      expect(@bracket.result(2,1)).to eq([0b011,11,12])
    end
    it "gets winner right" do
      expect(@bracket.result(3,0)).to eq([0b100,4,11])
    end
  end
end
