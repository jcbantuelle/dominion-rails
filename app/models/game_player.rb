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

  def deck
    player_cards.deck
  end

  def hand
    player_cards.hand
  end

  def discard
    player_cards.discard
  end

  def shuffle_discard_into_deck
    discard.shuffle.each_with_index do |card, index|
      card.update(card_order: index+1, state: 'deck')
    end
  end

  def discard_revealed
    player_cards.revealed.update_all state: 'discard'
  end

  def score
    player_cards.map{ |card| card.value if card.respond_to? :value }.inject(:+)
  end

end
