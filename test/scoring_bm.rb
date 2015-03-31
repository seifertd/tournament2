require 'benchmark'
require 'bracket'
require 'basic_scorer'


n = 10_000
teams = (0..63).to_a.map{|n| "t#{n}".to_sym }
bracket = Bracket.random_bracket(teams)
scorer = BasicScorer.new(teams, bracket)

puts "#{n} scores of perfect bracket"
Benchmark.bm(10) do |x|
  x.report(:basic) do
    n.times { scorer.score(bracket) }
  end
end
