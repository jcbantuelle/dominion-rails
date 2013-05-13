class Card < ActiveRecord::Base

  KINGDOM_SETS = {
    base: %w(moat chapel cellar chancellor village woodcutter workshop bureaucrat feast gardens militia moneylender remodel smithy spy thief throne_room council_room festival laboratory library market mine witch adventurer)
  }

  def self.generate_kingdom_cards(game)
    SETS.values.flatten.shuffle.take(10)
  end

  def self.generate_victory_cards(game)
    %w(estate duchy province)
  end

  def self.generate_treasure_cards(game)
    %w(copper silver gold)
  end

  def self.generate_starting_deck(game)
    {
      victory: %w(estate),
      treasure: %w(copper)
    }
  end

end
