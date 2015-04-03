module Tournament2
  class BasicScorer < Scorer
    NAME = 'Basic'
    def score_of(round, winner, loser)
      2 ** round
    end
    def name
      NAME
    end
    def description
      "Each correct pick is equal to the round number."
    end
    Scorer.register(NAME, self)
  end
end
