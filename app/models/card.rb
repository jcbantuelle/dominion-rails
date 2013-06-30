class Card < ActiveRecord::Base

  scope :card_type, ->(card_type) { where({card_type => true}) }
  scope :card_name, ->(card_name) { where(name: card_name) }

  after_find :load_card_module

  def self.generate_cards
    generate_kingdom_cards + generate_victory_cards + generate_treasure_cards + generate_miscellaneous_cards
  end

  def self.generate_kingdom_cards
    cards = card_type(:kingdom)
    cards.shuffle.take(10)
  end

  def self.generate_victory_cards
    card_type(:victory)
  end

  def self.generate_treasure_cards
    card_type(:treasure)
  end

  def self.generate_miscellaneous_cards
    [card_by_name('curse')]
  end

  def self.generate_starting_deck
    ([card_by_name('estate')]*3) + ([card_by_name('copper')]*7)
  end

  def self.card_by_name(card_name)
    card_name(card_name).first
  end

  def load_card_module
    extend name.classify.constantize
  end

end
