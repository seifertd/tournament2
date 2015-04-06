module Tournament2
  Team = Struct.new(:name, :short_name, :seed, :index)
  def self.ncaa_teams
    seeds = [1,16,8,9,5,12,4,13,6,11,3,14,7,10,2,15]
    (0..63).to_a.map{|n| Tournament2::Team.new("Team#{n}", "t#{n}", seeds[n % 16], n)}
  end
end

require 'tournament2/bit_twiddle'
require 'tournament2/bracket'
require 'tournament2/scorer'
require 'tournament2/basic_scorer'
require 'tournament2/basic_scorer2'
require 'tournament2/josh_patashnik_scorer'
require 'tournament2/tweaked_josh_patashnik_scorer'
require 'tournament2/ffi_scorer'
require 'tournament2/text_view'
