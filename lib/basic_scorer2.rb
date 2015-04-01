require 'scorer'
require_relative "./bit_twiddle"

class BasicScorer2 < Scorer
  FR_MASK = 0xffffffff

  def score (picks)
    # round 1 score:
    fr_result = result_bracket.results & FR_MASK
    fr_picks = picks.results & FR_MASK
    fr_correct =  result_bracket.games_in_round(0) - BitTwiddle.bits_set_in(fr_result ^ fr_picks)
    score = [fr_correct, fr_correct]
    round = 1
    while round < result_bracket.rounds
      game = 0
      while game < result_bracket.games_in_round(round)
        result = result_bracket.final_result(round,game)
        pick = picks.final_result(round,game)
        if result && result[0] == pick[0]
          score[0] += score_of(round, result[1], result[2])
        end
        #puts "RESULT: #{result.inspect} PICK: #{pick.inspect} ROUND: #{round} GAME: #{game}"
        score[1] += score_of(round, (result || pick)[1], (result || pick)[2])
        game += 1
      end
      round += 1
    end
    score
  end

  def score_of(round, winner, loser)
    2 ** round
  end
end
