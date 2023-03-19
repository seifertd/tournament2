module Tournament2
  class UpsetScorer < Scorer
    MULTIPLIERS = [1,2,4,8,16,32]
    def score_of(round, winner, loser)
      MULTIPLIERS[round] + @teams[winner].seed
    end
    def self.scorer_name
      "Upset"
    end
    def self.description
      "Each correct pick is worth the seed number of the winning team plus a per round multiplier: #{MULTIPLIERS.join(', ')}"
    end
    Scorer.register(self)
  end
end
