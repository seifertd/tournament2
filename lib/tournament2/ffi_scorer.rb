require 'ffi'
module Tournament2
  module FFIScorerExt
    class ScoreObj < FFI::Struct
      layout :score, :int, :max, :int
    end
    extend FFI::Library
    ffi_lib 'c'
    ffi_lib './ext/scorer.so'
    attach_function :ffi_games_in_round, [:int, :int], :int
    attach_function :ffi_score, [:int, :int, :pointer, :pointer, ScoreObj.by_ref], :void
  end
  class FFIScorer < Scorer
    def initialize(teams, bracket)
      super
      if bracket
        result_bracket.reset_final_results
        @bracket_picks = FFI::MemoryPointer.new(:int, result_bracket.total_games * 3)
        @picks_picks = FFI::MemoryPointer.new(:int, result_bracket.total_games * 3)
        @bracket_picks.write_array_of_int(result_bracket.flattened_final_results)
        @score = FFIScorerExt::ScoreObj.new
      end
    end
    def name
      self.class.name
    end
    def score(picks)
      @picks_picks.write_array_of_int(picks.flattened_final_results)
      FFIScorerExt.ffi_score(result_bracket.number_of_teams, result_bracket.rounds, @bracket_picks, @picks_picks, @score)
      [@score[:score], @score[:max]]
    end
    def score_of(round, winner, loser)
      2 ** round
    end
    def description
      "Super fast version of basic scorer"
    end
    Scorer.register(self.class.name, self)
  end
end
