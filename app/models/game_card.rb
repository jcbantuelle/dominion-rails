class GameCard < ActiveRecord::Base
  belongs_to :game
  belongs_to :card

  def kingdom?
    card.kingdom?
  end

  def victory?
    card.victory?
  end

  def treasure?
    card.treasure?
  end

  def type_class
    card.type.map(&:to_s).join(' ')
  end

  def name
    card.name
  end

  def cost
    card.cost
  end

  def json
    {
      name: name,
      type_class: type_class,
      cost: cost[:coin],
      remaining: remaining,
      title: name.titleize
    }
  end
end
