class GameTrash < ActiveRecord::Base
  belongs_to :game
  belongs_to :card

  def name
    card.name
  end

  def type_class
    card.type_class
  end

  def of_type(type)
    type_class.include?(type)
  end

  def json(game, turn)
    {
      id: id,
      name: name,
      type_class: type_class,
      title: name.titleize
    }
  end

  def costs_less_than?(coin, potion)
    card_cost = calculated_cost(game, game.current_turn)
    (card_cost[:potion].nil? || card_cost[:potion] <= potion) && card_cost[:coin] < coin
  end

  def calculated_cost(game_record, turn)
    if name == 'ruins' || name == 'knights'
      top_card = mixed_game_cards.first.card
      top_card.calculated_cost(game_record, turn)
    else
      card.calculated_cost(game_record, turn)
    end
  end
end
