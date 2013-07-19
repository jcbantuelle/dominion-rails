class PlayerCard < ActiveRecord::Base
  belongs_to :game_player
  belongs_to :card

  scope :ordered, ->{ order 'card_order, card_id' }
  scope :deck, ->{ where state: 'deck' }
  scope :hand, ->{ where state: 'hand' }
  scope :discard, ->{ where state: 'discard' }

end
