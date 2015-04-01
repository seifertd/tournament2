require 'benchmark'
require 'tournament2'


n = 10_000
teams = (0..63).to_a.map{|n| "t#{n}".to_sym }
bracket = Tournament2::Bracket.random_bracket(teams)
scorer = Tournament2::BasicScorer.new(teams, bracket)
scorer2 = Tournament2::BasicScorer2.new(teams, bracket)

puts "#{n} scores of perfect bracket"
Benchmark.bm(10) do |x|
  x.report(:basic) do
    n.times { scorer.score(bracket) }
  end
  x.report(:basic2) do
    n.times { scorer2.score(bracket) }
  end
end
