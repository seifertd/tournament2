class Bracket
  attr_accessor :results, :rounds, :teams, :played
  def initialize(teams)
    @teams = teams || [:t1, :t2, :t3, :t4]
    @rounds = (Math.log(@teams.size) / Math.log(2)).to_i
    @results = 0
    @played = 0
    @round = 0
  end

  def total_games
    @teams.size - 1
  end

  def games_played
    self.class.bits_set_in @played
  end

  def games_played_in_round(round = nil)
    round ||= @round
    self.class.bits_set_in ((@played >> round_offset(round)) & round_mask(round))
  end

  def games_in_round(round = nil)
    round ||= @round
    games = (@teams.size / 2) / (2**round)
    games
  end

  def round_mask(round = nil)
    round ||= @round
    2 ** games_in_round(round) - 1
  end

  def round_offset(round = nil)
    round ||= @round
    round == 0 ? 0 : (@teams.size - games_in_round(round-1))
  end

  def record_win_by(team)
    if complete?
      raise "No more games to be played in this bracket."
    end
    info = match_info(team)
    if !info[:alive]
      raise "Team #{team} has been eliminated"
    end
    #puts "  -> INFO: #{info.inspect}"
    @results |= (info[:team_bit] << info[:match_offset])
    @played |= (1 << info[:match_offset])
    if games_played_in_round >= games_in_round
      @round += 1
    end
    @results
  end

  def complete?
    games_played >= total_games
  end

  def match_info(team, round = @rounds)
    team_number = @teams.index(team)
    team_bit = team_number % 2
    raise "Team does not exist: #{team}" if team_number.nil?
    win_number = 0
    results_number = 0
    match_base = 0
    match_offset = match_base + team_number / 2
    alive = true
    r = 0
    while alive && ((@played >> match_offset) & 1) == 1 && r <= round
      results_number |= (((@results >> match_offset) & 1) << r)
      win_number |= (team_bit << r)
      alive = results_number == win_number
      break if !alive || r >= round
      match_base += games_in_round(r)
      r += 1
      team_number /= 2
      team_bit = team_number % 2
      match_offset = match_base + team_number / 2
    end
    {alive: alive, round: r, team_bit: team_bit, team_number: team_number, result: results_number, win_number: win_number, match_offset: match_offset} 
  end


  def team_alive(team)
    match_info(team)[:alive]
  end

  def print
    bit_format = "%0#{total_games}b"
    puts "RESULTS: #{bit_format % @results}"
    puts " PLAYED: #{bit_format % @played}"
  end

  # 64 bit hamming weight
  M1  = 0x5555555555555555
  M2  = 0x3333333333333333
  M4  = 0x0f0f0f0f0f0f0f0f
  M8  = 0x00ff00ff00ff00ff
  M16 = 0x0000ffff0000ffff
  M32 = 0x00000000ffffffff
  def self.bits_set_in(i)
    i -= (i >> 1) & M1
    i = (i & M2) + ((i >> 2) & M2)
    i = (i + (i >> 4)) & M4
    i += i >> 8
    i += i >> 16
    i += i >> 32
    i & 0x7f
  end

  def self.random_bracket(number_teams)
    teams = (1..number_teams).to_a.map {|n| "t#{n}".to_sym}
    match = 1
    b = Bracket.new(teams)
    while teams.size > 1
      new_teams = []
      #puts teams.inspect
      teams.each_slice(2) do |t1, t2|
        if rand.round == 0
          new_teams.push t1
        else
          new_teams.push t2
        end
        #puts "Match #{match}: #{t1} vs #{t2} => #{new_teams.last}"
        b.record_win_by new_teams.last
        match += 1
      end
      teams = new_teams
    end
    b
  end
end
