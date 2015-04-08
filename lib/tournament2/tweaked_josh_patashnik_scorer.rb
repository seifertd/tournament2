module Tournament2
  class TweakedJoshPatashnikScorer < Scorer
    MULTIPLIERS = [1,2,4,8,12,22]
    def score_of(round, winner, loser)
      MULTIPLIERS[round] * @teams[winner].seed
    end
    def self.scorer_name
      "Tweaked Josh Patashnik"
    end
    def self.description
      "Tweak of the Josh Patashnik system that doesn't weight the final four and championship as high. Each correct pick is worth the seed number of the winning team times a per round multiplier: #{MULTIPLIERS.join(', ')}"
    end
    Scorer.register(self)
  end
end
