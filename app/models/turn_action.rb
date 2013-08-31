class TurnAction < ActiveRecord::Base
  belongs_to :game
  belongs_to :game_player
end
