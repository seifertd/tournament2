module Tournament2
  class BasicScorer < Scorer
    def score_of(round, winner, loser)
      2 ** round
    end
    Scorer.register('basic', self)
  end
end
