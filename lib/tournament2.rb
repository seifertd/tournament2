module Tournament2
  Team = Struct.new(:name, :short_name, :seed, :index)
end

require 'tournament2/bit_twiddle'
require 'tournament2/bracket'
require 'tournament2/scorer'
require 'tournament2/basic_scorer'
require 'tournament2/basic_scorer2'
require 'tournament2/josh_patashnik_scorer'
require 'tournament2/text_view'
