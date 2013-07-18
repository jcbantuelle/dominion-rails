class GamePlayer < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  has_many :player_cards, ->{ ordered }, dependent: :destroy
  has_many :turns

  scope :ordered, ->{ order 'turn_order' }
  scope :timed_out, ->{ where accepted: false }

  def username
    player.username
  end

end
