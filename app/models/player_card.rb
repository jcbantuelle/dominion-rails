class PlayerCard < ActiveRecord::Base
  belongs_to :game_player
  belongs_to :card
end
