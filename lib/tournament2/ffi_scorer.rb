require 'ffi'
module Tournament2
  module FFIScorerExt
    SCORING_METHODS = [:basic, 1, :josh_patashnik, :upset, :constant_value, :seed_difference]
    extend FFI::Library
    ffi_lib 'c'
    ffi_lib './ext/scorer.so'
    class ScoreObj < FFI::Struct
      layout :score, :int, :max, :int
    end
    enum :scoring_method, SCORING_METHODS
    attach_function :t2_score, [:int, :int, :scoring_method, :pointer, :pointer, ScoreObj.by_ref], :void
    attach_function :t2_score_of, [:scoring_method, :int, :int, :int], :int
    attach_function :t2_set_round_factor, [:int, :int], :void
  end
  class FFIScorer
    attr_reader :scoring_method
    def initialize(scoring_method, bracket)
      raise "Invalid scoring method: #{scoring_method.inspect}" unless FFIScorerExt::SCORING_METHODS.include?(scoring_method) && scoring_method != 1

      @scoring_method = scoring_method
      if bracket
        bracket.reset_final_results
        @bracket_picks = FFI::MemoryPointer.new(:int, bracket.total_games * 3)
        @picks_picks = FFI::MemoryPointer.new(:int, bracket.total_games * 3)
        @bracket_picks.write_array_of_int(bracket.flattened_final_results)
        @score = FFIScorerExt::ScoreObj.new
      end

    end
    def self.scorer_name
      "FFI Scorer"
    end
    def self.description
      "Scorer implemented using FFI for speed"
    end
    def self.set_round_factors(factors)
      factors.each.with_index do |value, round|
        FFIScorerExt.t2_set_round_factor(round, value)
      end
    end
    def score(picks)
      @picks_picks.write_array_of_int(picks.flattened_final_results)
      FFIScorerExt.t2_score(picks.number_of_teams, picks.rounds, @scoring_method, @bracket_picks, @picks_picks, @score)
      [@score[:score], @score[:max]]
    end
    def score_of(round, winner, loser)
      FFIScorerExt.t2_score_of(@scoring_method, round, winner, loser)
    end
  end
end
