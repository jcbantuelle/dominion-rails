class GameCard < ActiveRecord::Base

  include CardMethods

  belongs_to :game
  belongs_to :card
  has_many :mixed_game_cards, ->{ ordered }, dependent: :destroy

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

  def name
    card.name
  end

  def treasure_card?
    top_card.treasure_card?
  end

  def victory_card?
    top_card.victory_card?
  end

  def attack_card?
    top_card.attack_card?
  end

  def action_card?
    top_card.action_card?
  end

  def type_class
    top_card.type_class
  end

  def top_card
    name == 'ruins' || name == 'knights' ? mixed_game_cards.first : card
  end

  def belongs_to_set?(set)
    card.belongs_to_set?(set)
  end

  def available?
    remaining > 0
  end

  def calculated_cost(game_record, turn)
    if top_card.nil?
      {coin: 0, potion: 0}
    else
      top_card.calculated_cost(game_record, turn)
    end
  end

  def add_to_pile(count)
    update remaining: (remaining + count)
  end

  def json(game_record, turn)
    if top_card.nil?
      card_cost = {
        coin: 0,
        potion: 0
      }
      card_name = 'placeholder'
      card_type_class = ''
    else
      card_cost = top_card.calculated_cost(game_record, turn)
      card_name = top_card.name
      card_type_class = top_card.type_class
    end

    {
      id: id,
      name: card_name,
      type_class: card_type_class,
      coin_cost: card_cost[:coin],
      potion_cost: card_cost[:potion],
      remaining: remaining,
      title: name.titleize
    }
  end
end
