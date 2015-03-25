require 'bracket'

b = Bracket.random_bracket(64)
0.upto(b.rounds - 1) do |r|
  puts "Games in round #{r} = #{b.games_in_round(r)}"
end
puts b.inspect
b.print
puts "Bracket complete? #{b.complete?}"
b.teams.each do |team|
  puts "Match info #{team.inspect}, round = 1: #{b.match_info(team, 1)}"
end

#teams = [:t1,:t2,:t3,:t4,:t5,:t6,:t7,:t8, :t9, :t10, :t11, :t12, :t13, :t14, :t15, :t16]
#b = Bracket.new(teams)
#[:t1, :t4, :t6, :t8, :t10, :t11, :t13, :t16, :t1, :t8, :t11, :t13, :t1, :t13, :t1].each do |t|
#  puts "Team #{t.inspect} wins"
#  b.record_win_by(t)
#  b.print
#end
#teams.each do |t|
#  puts "Team #{t.inspect} alive? #{b.team_alive(t)}"
#end
#puts "Bracket complete? #{b.complete?}"
