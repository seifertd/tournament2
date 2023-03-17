module Tournament2
  class BasicScorer < Scorer
    def score_of(round, winner, loser)
      2 ** round
    end
    def self.scorer_name
      "Basic" 
    end
    def self.description
      "Each correct pick is equal to the round number."
    end
    Scorer.register(self)
  end
end
