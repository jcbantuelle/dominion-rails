class Turn < ActiveRecord::Base
  belongs_to :game
  belongs_to :game_player

  scope :ordered, ->{ order 'turn DESC' }
end
