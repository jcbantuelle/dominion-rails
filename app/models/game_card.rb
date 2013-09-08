class GameCard < ActiveRecord::Base
  belongs_to :game
  belongs_to :card

  scope :by_card_id, ->(card_id) { where card_id: card_id }
  scope :by_game_id_and_card_name, ->(game_id, card_name) { joins(:card).where('cards.name = ? AND game_id = ?', card_name, game_id) }
  scope :empty_piles, -> { where(remaining: 0).joins(:card).where('cards.supply = ?', true) }

  def kingdom?
    card.kingdom?
  end

  def victory?
    card.victory?
  end

  def treasure?
    card.treasure?
  end

  def supply?
    card.supply?
  end

  def treasure_card?
    card.treasure_card?
  end

  def belongs_to_set?(set)
    card.belongs_to_set?(set)
  end

  def available?
    remaining > 0
  end

  def type_class
    card.type_class
  end

  def name
    card.name
  end

  def calculated_cost(game_record)
    card.calculated_cost(game_record)
  end

  def costs_less_than?(coin, potion)
    card_cost = calculated_cost(game)
    (card_cost[:potion].nil? || card_cost[:potion] <= potion) && card_cost[:coin] < coin
  end

  def costs_same_as?(cost)
    card_cost = calculated_cost(game)
    card_cost[:potion] == cost[:potion] && card_cost[:coin] == cost[:coin]
  end

  def add_to_pile(count)
    update remaining: (remaining + count)
  end

  def json
    card_cost = calculated_cost(game)
    {
      id: id,
      name: name,
      type_class: type_class,
      coin_cost: card_cost[:coin],
      potion_cost: card_cost[:potion],
      remaining: remaining,
      title: name.titleize
    }
  end
end
