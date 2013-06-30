class GameCard < ActiveRecord::Base
  belongs_to :game
  belongs_to :card
end
