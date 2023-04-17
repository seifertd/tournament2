require_relative '../lib/tournament2'
require 'json'

seeds = [1,16,8,9,5,12,4,13,6,11,3,14,7,10,2,15]
idx = 0
teams = File.open("./2023/teams.txt").readlines.map(&:chomp).map{|s| s.split(',')}.map do |name, short_name|
  t = Tournament2::Team.new(name, short_name, seeds[idx % 16], idx)
  idx += 1
  t
end
puts "Read #{teams.size} teams"
team_to_index = {}
teams.each {|t| team_to_index[t.short_name] = t.index}

if team_to_index.size != 64
  raise "Duplicate short names somewhere!"
end

# Set up tourny bracket
tourney = Tournament2::Bracket.new(teams.size)

# Read entries
entries = {}
Dir.foreach("./2023/entries") do |entry_file|
  next if [".", ".."].include?(entry_file)
  puts "ENTRY FILE: #{entry_file}"
  entry_name = File.basename(entry_file, '.txt')
  bracket = Tournament2::Bracket.new(teams.size)
  tie_break = nil
  File.open("./2023/entries/#{entry_file}").readlines.each do |pick|
    pick.chomp!
    if pick.match(/\d+/)
      tie_break = pick.to_i
    else
      if idx = team_to_index[pick]
        begin
          bracket.record_win_by(idx)
        rescue Exception => e
          puts "COULD NOT RECORD WIN BY TEAM: #{pick}(#{idx}): #{e}"
          puts team_to_index.inspect
          raise e
        end
      else
        raise "Could not map name #{pick} to a team"
      end
    end
  end
  entries[entry_name] = [tie_break, bracket]
end

# Tourny Results:
tourney.record_win_by(team_to_index["Ala"])
tourney.record_win_by(team_to_index["Mrl"])
tourney.record_win_by(team_to_index["SDS"])
tourney.record_win_by(team_to_index["Fur"])
tourney.record_win_by(team_to_index["Cre"])
tourney.record_win_by(team_to_index["Bay"])
tourney.record_win_by(team_to_index["Mis"])
tourney.record_win_by(team_to_index["Pri"])
tourney.record_win_by(team_to_index["FDU"])
tourney.record_win_by(team_to_index["FAU"])
tourney.record_win_by(team_to_index["Duk"])
tourney.record_win_by(team_to_index["Ten"])
tourney.record_win_by(team_to_index["Ken"])
tourney.record_win_by(team_to_index["KSt"])
tourney.record_win_by(team_to_index["MiS"])
tourney.record_win_by(team_to_index["Mar"])
tourney.record_win_by(team_to_index["Hou"])
tourney.record_win_by(team_to_index["Aub"])
tourney.record_win_by(team_to_index["MiF"])
tourney.record_win_by(team_to_index["Ind"])
tourney.record_win_by(team_to_index["Pit"])
tourney.record_win_by(team_to_index["Xav"])
tourney.record_win_by(team_to_index["PSt"])
tourney.record_win_by(team_to_index["Tex"])
tourney.record_win_by(team_to_index["Kan"])
tourney.record_win_by(team_to_index["Ark"])
tourney.record_win_by(team_to_index["StM"])
tourney.record_win_by(team_to_index["UCn"])
tourney.record_win_by(team_to_index["TCU"])
tourney.record_win_by(team_to_index["Gon"])
tourney.record_win_by(team_to_index["NWn"])
tourney.record_win_by(team_to_index["UCL"])

# Round 2 - Day 1
tourney.record_win_by(team_to_index["SDS"])
tourney.record_win_by(team_to_index["Ten"])
tourney.record_win_by(team_to_index["Pri"])
tourney.record_win_by(team_to_index["Ark"])
tourney.record_win_by(team_to_index["Hou"])
tourney.record_win_by(team_to_index["Tex"])
tourney.record_win_by(team_to_index["UCL"])
tourney.record_win_by(team_to_index["Ala"])

# Round 2 - Day 2
tourney.record_win_by(team_to_index["Xav"])
tourney.record_win_by(team_to_index["KSt"])
tourney.record_win_by(team_to_index["MiS"])
tourney.record_win_by(team_to_index["Cre"])
tourney.record_win_by(team_to_index["FAU"])
tourney.record_win_by(team_to_index["UCn"])
tourney.record_win_by(team_to_index["MiF"])
tourney.record_win_by(team_to_index["Gon"])

# Round 3 - Day 1
tourney.record_win_by(team_to_index["UCn"])
tourney.record_win_by(team_to_index["KSt"])
tourney.record_win_by(team_to_index["FAU"])
tourney.record_win_by(team_to_index["Gon"])

# Round 3 - Day 1
tourney.record_win_by(team_to_index["SDS"])
tourney.record_win_by(team_to_index["MiF"])
tourney.record_win_by(team_to_index["Cre"])
tourney.record_win_by(team_to_index["Tex"])

puts "Total Games In Tourney: #{tourney.total_games}"
puts "Games Played: #{tourney.games_played}"
puts tourney.to_s

if !STDIN.tty? && !STDIN.closed? || ARGF.filename != ?-
  puts "Reading possibilities output ..."
  possibilities = JSON.parse(ARGF.read)
  pool = possibilities["pool"]
  outcomes = pool["numOutcomes"]
  printf "%10s  %3s  %5s %4s %4s  %3s  %5s  %-21s\n", "",       "Tie",   "Curr",  "Max",  "Min",  "Max",   "Win",   "" 
  printf "%10s %5s %5s %4s %4s %5s %6s %-21s\n", "Entry", "Break", "Score", "Rank", "Rank", "Score", "Chance", "Top Champs"
  puts "-"*70
  possibilities["picks"].sort_by{|e| [-e["champs"].values.sum, e["maxRank"], e["minRank"], -e["maxScore"]] }.each do |entry|
    tie_break, bracket = entries[entry["name"]]
    scorer = Tournament2::UpsetScorer.new(teams, tourney)
    score, max_score = scorer.score(bracket)
    times_winning = entry["champs"].values.sum
    top_teams = entry["champs"].map{|tn, wins| [wins, tn.to_i]}.sort_by{|wins, tn| -wins}.map{|wins, tn| teams[tn]}[0..4]
    #puts "#{entry.inspect} #{bracket}"
    printf "%10s %5d %5d %4d %4d %5d %6.2f %-21s\n", entry["name"], tie_break, score, entry["maxRank"], entry["minRank"], entry["maxScore"], times_winning.to_f / outcomes * 100.0, top_teams.map{|t|t[:short_name]}.join(",")
  end
end

entries.each do |name, v|
  tie_break, bracket = v
  puts "#{bracket.to_s} #{name}"
end
