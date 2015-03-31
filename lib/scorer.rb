class Scorer
  attr_reader :result_bracket, :teams
  def initialize(teams, result_bracket)
    @teams = teams
    @result_bracket = result_bracket
  end

  def score(picks)
    score = [0,0]
    round = 0
    while round < result_bracket.rounds
      game = 0
      while game < result_bracket.games_in_round(round)
        result = result_bracket.final_result(round,game)
        pick = picks.final_result(round,game)
        if result
          if result[0] == pick[0]
            score[0] += score_of(round, result[1], result[2])
          end
          score[1] += score_of(round, result[1], result[2])
        else
          score[1] += score_of(round, pick[1], pick[2])
        end
        game += 1
      end
      round += 1
    end
    score
  end

  def score_of(round, winner, loser)
    raise "Not yet implemented"
  end
end
