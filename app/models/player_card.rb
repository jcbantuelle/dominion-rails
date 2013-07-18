class PlayerCard < ActiveRecord::Base
  belongs_to :game_player
  belongs_to :card

  scope :ordered, ->{ order 'card_order' }
  scope :deck, ->{ where state: 'deck' }

end
