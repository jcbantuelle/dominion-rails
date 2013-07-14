class GamePlayer < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  has_many :player_cards, dependent: :destroy
  has_many :turns

  scope :timed_out, ->{ where accepted: false }
  scope :ordered, ->{ order 'turn_order' }

  def username
    player.username
  end
end
