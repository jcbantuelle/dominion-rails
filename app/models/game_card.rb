class GameCard < ActiveRecord::Base
  belongs_to :game
  belongs_to :card

  scope :by_card_id, ->(card_id) { where card_id: card_id }

  def kingdom?
    card.kingdom?
  end

  def victory?
    card.victory?
  end

  def treasure?
    card.treasure?
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

  def cost
    card.cost
  end

  def json
    {
      id: id,
      name: name,
      type_class: type_class,
      cost: cost[:coin],
      remaining: remaining,
      title: name.titleize
    }
  end
end
