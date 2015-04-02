module Tournament2
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
          if result && result[0] == pick[0]
              score[0] += score_of(round, result[1], result[2])
          end
          score[1] += score_of(round, (result || pick)[1], (result || pick)[2])
          game += 1
        end
        round += 1
      end
      score
    end

    def score_of(round, winner, loser)
      raise "Not yet implemented"
    end

    def self.scorers
      @scorers ||= {}
    end

    def self.register(name, clazz)
      scorers[name] = clazz
    end

    def self.scorer_names
      scorers.keys
    end

    def self.scorer_by_name(name, teams, result_bracket)
      scorers[name].new(teams, result_bracket)
    end
  end
end
