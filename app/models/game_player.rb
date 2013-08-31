class GamePlayer < ActiveRecord::Base
  belongs_to :game
  belongs_to :player
  has_many :player_cards, ->{ ordered }, dependent: :destroy
  has_many :turns, ->{ ordered }
  has_many :turn_actions

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

  def duration
    player_cards.duration
  end

  def in_play
    player_cards.in_play
  end

  def shuffle_discard_into_deck
    discard.shuffle.each_with_index do |card, index|
      card.update(card_order: index+1, state: 'deck')
    end
  end

  def discard_revealed
    player_cards.revealed.update_all state: 'discard'
  end

  def point_cards
    player_cards.select{ |card| card.point_card? }
  end

  def score
    point_cards.map(&:value).inject(:+) + victory_tokens
  end

  def add_victory_tokens(amount)
    update_attribute :victory_tokens, victory_tokens + amount
  end

  def find_card_in_hand(name)
    card = Card.by_name name
    hand.select{ |c| c.card_id == card.id }.first
  end

  def find_card_in_play(name)
    card = Card.by_name name
    in_play.select{ |c| c.card_id == card.id }.first
  end

  def empty_deck?
    player_cards.deck.empty?
  end

  def empty_discard?
    player_cards.discard.empty?
  end

  def needs_reshuffle?
    empty_deck? && !empty_discard?
  end
end
