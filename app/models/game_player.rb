class GamePlayer < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  has_many :player_cards, dependent: :destroy

  scope :timed_out, ->{ where accepted: false }
  scope :ordered, ->{ order 'turn_order DESC' }

  def username
    player.username
  end
end
