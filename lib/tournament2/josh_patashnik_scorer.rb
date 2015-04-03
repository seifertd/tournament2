module Tournament2
  class JoshPatashnikScorer < Scorer
    MULTIPLIERS = [1,2,4,8,16,32]
    def score_of(round, winner, loser)
      MULTIPLIERS[round] * @teams[winner].seed
    end

    Scorer.register('Josh Patashnik', self)
  end
end
