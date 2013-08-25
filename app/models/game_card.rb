class GameCard < ActiveRecord::Base
  belongs_to :game
  belongs_to :card

  scope :by_card_id, ->(card_id) { where card_id: card_id }
  scope :by_game_id_and_card_name, ->(game_id, card_name) { joins(:card).where('cards.name = ? AND game_id = ?', card_name, game_id) }
  scope :empty_piles, -> { where remaining: 0 }

  def kingdom?
    card.kingdom?
  end

  def victory?
    card.victory?
  end

  def treasure?
    card.treasure?
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

  def cost(game)
    CardCostCalculater.new(game, card).cost
  end

  def json(game)
    {
      id: id,
      name: name,
      type_class: type_class,
      coin_cost: cost(game)[:coin],
      potion_cost: cost(game)[:potion],
      remaining: remaining,
      title: name.titleize
    }
  end
end
