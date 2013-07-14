class Turn < ActiveRecord::Base
  belongs_to :game
  belongs_to :game_player

  scope :ordered, ->{ order 'turn DESC' }

  def self.next(game)
    Turn.create game_player: game.current_turn_player, game: game, turn: game.turn, actions: 1, buys: 1, coins: 0
  end
end
