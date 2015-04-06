require 'benchmark'
require 'tournament2'


SEEDS = [1,16,8,9,5,12,4,13,6,11,3,14,7,10,2,15]
teams = (0..63).to_a.map{|n| Tournament2::Team.new("Team#{n}", "t#{n}".to_sym, SEEDS[n%16], n ) }
bracket = Tournament2::Bracket.random_bracket(teams)
picks = (0...10).to_a.map {|n| Tournament2::Bracket.random_bracket(teams)}
scorer = Tournament2::BasicScorer.new(teams, bracket)
scorer2 = Tournament2::BasicScorer2.new(teams, bracket)
joshp = Tournament2::Scorer.scorer_by_name("Josh Patashnik", teams, bracket)
ffi = Tournament2::FFIScorer.new(teams, bracket)

# WARM IT UP
picks.each do |p|
  scorer.score(p)
  scorer2.score(p)
  joshp.score(p)
  ffi.score(p)
end

n = 50_000
puts "#{n} scores of #{picks.size} random brackets"
Benchmark.bm(15) do |x|
  x.report(:basic) do
    n.times { picks.each {|p| scorer.score(p) } }
  end
  x.report(:basic2) do
    n.times { picks.each {|p| scorer2.score(p) } }
  end
  x.report(:josh_patashnik) do
    n.times { picks.each {|p| joshp.score(p) } }
  end
  x.report(:ffi_scorer) do
    n.times { picks.each {|p| ffi.score(p) } }
  end
end
