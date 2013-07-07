class GamePlayer < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  has_one :player_deck, dependent: :destroy

  scope :timed_out, ->{ where(accepted: false) }
end
