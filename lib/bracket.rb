require "memoist"

class Bracket
  extend Memoist
  attr_accessor :results, :rounds, :number_of_teams, :played, :round
  def initialize(number_of_teams)
    @number_of_teams = number_of_teams
    @rounds = (Math.log(@number_of_teams) / Math.log(2)).to_i
    @results = 0
    @played = 0
    @round = 0
  end

  def total_games
    @number_of_teams - 1
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
    (@number_of_teams / 2) / (2**round)
  end

  def round_mask(round = nil)
    round ||= @round
    2 ** games_in_round(round) - 1
  end

  def round_offset(round = nil)
    round ||= @round
    round == 0 ? 0 : (@number_of_teams - games_in_round(round-1))
  end

  def winner
    played?(@rounds - 1, 0) && result(@rounds - 1, 0).first
  end

  def played?(round, game)
    ((@played >> result_offset(round,game)) & 1) == 1
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
    @results |= (info[:team_bit] << info[:result_offset])
    @played |= (1 << info[:result_offset])
    if games_played_in_round >= games_in_round
      @round += 1
    end
    @results
  end

  def complete?
    games_played >= total_games
  end

  def match_info(team_id, round = @rounds)
    alive = true
    win_result = 0
    r = 0
    game = team_id / 2
    team_bit = team_id % 2
    while alive && played?(r,game) && r <= round
      win_result |= (team_bit << r)
      alive = (win_result == result(r,game).first)
      break if !alive || r >= round
      r += 1
      team_bit = game % 2
      game /= 2
    end
    #puts " -> team_id:#{team_id} alive: #{alive} round:#{round} r:#{r} team_bit: #{team_bit} game: #{game} result_offset:#{result_offset(r,game)} actual:#{result(r,game)} to_win: #{win_result} ? #{win_result == result(r,game)}"
    {alive: alive, round: r, team_bit: team_bit, team_id: team_id, team_round_index: team_id, actual_result: result(r,game), to_win_result: win_result, result_offset: result_offset(r,game)} 
  end

  def result_offset(round, game)
    round_offset(round) + game
  end

  def result(round, game, check_complete = true)
    if check_complete && complete?
      return final_result(round, game)
    end
    if !played?(round, game)
      return nil
    end
    #puts " => result(#{round},#{game})"
    result = 0
    r = round
    g = game
    result_bit = ((@results >> result_offset(r,g)) & 1)
    while r >= 0
      b = ((@results >> result_offset(r,g)) & 1)
      result |= (b << r)
      #puts "     ... bit:#{b} result:#{result} round: #{r} game: #{game}"
      r -= 1
      g = g * 2 + b
    end
    if round == 0
      loser = g + 1 - 2 * result_bit
    else
      previous_game = game * 2 + result_bit + 1 - 2 * result_bit
      loser = result(round-1, previous_game)
      loser = loser[1]
    end
    [result, g, loser]
  end

  def final_result(round, game)
    result(round, game, false)
  end
  memoize :final_result

  def team_alive(team)
    match_info(team, @round)[:alive]
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

  def self.random_bracket(teams)
    current_teams = teams
    match = 1
    b = Bracket.new(teams.size)
    while current_teams.size > 1
      new_teams = []
      #puts teams.inspect
      current_teams.each_slice(2) do |t1, t2|
        if rand.round == 0
          new_teams.push t1
        else
          new_teams.push t2
        end
        #puts "Match #{match}: #{t1} vs #{t2} => #{new_teams.last}"
        b.record_win_by teams.index(new_teams.last)
        #b.print
        match += 1
      end
      current_teams = new_teams
    end
    b
  end
end
