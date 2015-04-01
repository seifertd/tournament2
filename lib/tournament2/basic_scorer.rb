require 'scorer'

class BasicScorer < Scorer
  def score_of(round, winner, loser)
    2 ** round
  end
end
