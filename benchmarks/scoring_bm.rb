require 'benchmark'
require 'tournament2'


SEEDS = [1,16,8,9,5,12,4,13,6,11,3,14,7,10,2,15]
teams = (0..63).to_a.map{|n| Tournament2::Team.new("Team#{n}", "t#{n}".to_sym, SEEDS[n%16], n ) }
bracket = Tournament2::Bracket.random_bracket(teams)
scorer = Tournament2::BasicScorer.new(teams, bracket)
scorer2 = Tournament2::BasicScorer2.new(teams, bracket)
joshp = Tournament2::Scorer.scorer_by_name("Josh Patashnik", teams, bracket)

n = 50_000
puts "#{n} scores of perfect bracket"
Benchmark.bm(15) do |x|
  x.report(:basic) do
    n.times { scorer.score(bracket) }
  end
  x.report(:basic2) do
    n.times { scorer2.score(bracket) }
  end
  x.report(:josh_patashnik) do
    n.times { joshp.score(bracket) }
  end
end
