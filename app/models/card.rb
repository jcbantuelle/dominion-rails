class Card < ActiveRecord::Base

  scope :card_type, ->(card_type) { where({card_type => true}) }
  scope :card_name, ->(card_name) { where(name: card_name) }
  scope :sets, ->(sets) { where(set: sets) }

  def self.generate_kingdom_cards(game, sets = nil)
    cards = card_type(:kingdom)
    cards = cards.sets(sets) unless sets.nil?
    cards.shuffle.take(10)
  end

  def self.generate_victory_cards(game)
    card_type(:victory)
  end

  def self.generate_treasure_cards(game)
    card_type(:treasure)
  end

  def self.generate_starting_deck(game)
    {
      victory: [card_by_name('estate')],
      treasure: [card_by_name('copper')]
    }
  end

  def self.generate_miscellaneous_cards(game)
    [card_by_name('curse')]
  end

  def self.card_by_name(card_name)
    card_name(card_name).first
  end

end
