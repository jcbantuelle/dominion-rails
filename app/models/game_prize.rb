class GamePrize < ActiveRecord::Base

  include CardMethods

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

  def calculated_cost(game_record, turn)
    if name == 'ruins' || name == 'knights'
      top_card = mixed_game_cards.first.card
      top_card.calculated_cost(game_record, turn)
    else
      card.calculated_cost(game_record, turn)
    end
  end
end
