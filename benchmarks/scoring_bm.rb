require 'benchmark'
require 'tournament2'


SEEDS = [1,16,8,9,5,12,4,13,6,11,3,14,7,10,2,15]
teams = (0..63).to_a.map{|n| Tournament2::Team.new("Team#{n}", "t#{n}".to_sym, SEEDS[n%16], n ) }
bracket = Tournament2::Bracket.random_bracket(teams)
picks = (0...10).to_a.map {|n| Tournament2::Bracket.random_bracket(teams)}
scorer = Tournament2::BasicScorer.new(teams, bracket)
scorer2 = Tournament2::BasicScorer2.new(teams, bracket)
joshp = Tournament2::Scorer.scorer_by_name("Josh Patashnik", teams, bracket)
ffi_basic = Tournament2::FFIScorer.new(:basic, bracket)
ffi_joshp = Tournament2::FFIScorer.new(:josh_patashnik, bracket)
ffi_tjoshp = Tournament2::FFIScorer.new(:tweaked_josh_patashnik, bracket)
ffi_cv = Tournament2::FFIScorer.new(:constant_value, bracket)
ffi_upset = Tournament2::FFIScorer.new(:upset, bracket)

# WARM IT UP
picks.each do |p|
  scorer.score(p)
  scorer2.score(p)
  joshp.score(p)
  ffi_basic.score(p)
  ffi_joshp.score(p)
  ffi_tjoshp.score(p)
  ffi_cv.score(p)
  ffi_upset.score(p)
end

n = 10_000
puts "#{n} scores of #{picks.size} random brackets"
run_test = Proc.new do |n, picks, scorer|
  i = 0
  np = picks.length
  while i < n
    j = 0
    while j < np
      scorer.score picks[j]
      j += 1
    end
    i += 1
  end
end
Benchmark.bm(15) do |x|
  x.report(:basic) do
    run_test[n, picks, scorer]
  end
  x.report(:basic2) do
    run_test[n, picks, scorer2]
  end
  x.report(:josh_patashnik) do
    run_test[n, picks, joshp]
  end
  x.report(:ffi_basic) do
    run_test[n, picks, ffi_basic]
  end
  x.report(:ffi_josh_p) do
    run_test[n, picks, ffi_joshp]
  end
  x.report(:ffi_twk_josh_p) do
    run_test[n, picks, ffi_tjoshp]
  end
  x.report(:ffi_constant_v) do
    run_test[n, picks, ffi_cv]
  end
  x.report(:ffi_upset) do
    run_test[n, picks, ffi_upset]
  end
end
