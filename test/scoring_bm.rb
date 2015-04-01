require 'benchmark'
require 'bracket'
require 'basic_scorer'
require 'basic_scorer2'


n = 10_000
teams = (0..63).to_a.map{|n| "t#{n}".to_sym }
bracket = Bracket.random_bracket(teams)
scorer = BasicScorer.new(teams, bracket)
scorer2 = BasicScorer2.new(teams, bracket)

puts "#{n} scores of perfect bracket"
Benchmark.bm(10) do |x|
  x.report(:basic) do
    n.times { scorer.score(bracket) }
  end
  x.report(:basic2) do
    n.times { scorer2.score(bracket) }
  end
end
