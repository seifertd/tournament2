require 'ffi'

module FFIScorer
  class ScoreObj < FFI::Struct
    layout :score, :int, :max, :int
  end
  extend FFI::Library
  ffi_lib 'c'
  ffi_lib './ext/scorer.so'
  attach_function :t2_games_in_round, [:int, :int], :int
  attach_function :t2_score, [:int, :int, :int, :pointer, :pointer, ScoreObj.by_ref], :void
end

puts "TESTING GAMES IN NCCA ROUNDS:"
0.upto(5) do |r|
  puts "GAMES IN ROUND #{r+1}: #{FFIScorer.t2_games_in_round(64, r)}"
end

puts "SCORE:"
require_relative './lib/tournament2'
SEEDS = [1,16,8,9,5,12,4,13,6,11,3,14,7,10,2,15]
teams = (0..63).to_a.map{|n| Tournament2::Team.new("Team#{n}", "t#{n}", SEEDS[n % 16], n)}
b = Tournament2::Bracket.random_bracket(teams)
s = Tournament2::BasicScorer.new(teams, b)
puts "BRACKET SCORE: #{s.score(b)}"
puts "BRACKET FINAL RESULTS: #{b.final_results.inspect}"
bracket_picks = b.final_results.flatten
bracket_input = FFI::MemoryPointer.new(:int, bracket_picks.size)
bracket_input.write_array_of_int(bracket_picks)

results = [0,0];
results_pointer = FFI::MemoryPointer.new(:int, 2)
results_pointer.write_array_of_int(results)

score = FFIScorer::ScoreObj.new
score[:score] = -1
score[:max] = -1 
FFIScorer.t2_score(64, 6, 3, bracket_input, bracket_input, score)

puts "GOT SCORE: #{score.inspect}: SCORE: #{score[:score]} MAX: #{score[:max]}"
