class GameCard < ActiveRecord::Base
  belongs_to :game
  belongs_to :card

  scope :by_card_id, ->(card_id) { where card_id: card_id }
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
    base_cost = card.cost game
    base_coin = base_cost[:coin]

    discount = 0
    discount += game.current_turn.global_discount unless game.current_turn.nil?

    calculated_coin = base_coin - discount
    calculated_coin = 0 if calculated_coin < 0

    cost_values = [[:coin, calculated_coin]]
    cost_values << [:potion, base_cost[:potion]] unless base_cost[:potion].nil?

    Hash[cost_values]
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
