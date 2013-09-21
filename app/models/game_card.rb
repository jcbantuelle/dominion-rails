class GameCard < ActiveRecord::Base
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

  def treasure_card?
    card.treasure_card?
  end

  def attack_card?
    card.attack_card?
  end

  def action_card?
    card.action_card?
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

  def calculated_cost(game_record, turn)
    if name == 'ruins' || name == 'knights'
      top_card = mixed_game_cards.first.card
      top_card.calculated_cost(game_record, turn)
    else
      card.calculated_cost(game_record, turn)
    end
  end

  def costs_less_than?(coin, potion)
    card_cost = calculated_cost(game, game.current_turn)
    (card_cost[:potion].nil? || card_cost[:potion] <= potion) && card_cost[:coin] < coin
  end

  def costs_same_as?(cost)
    card_cost = calculated_cost(game, game.current_turn)
    card_cost[:potion] == cost[:potion] && card_cost[:coin] == cost[:coin]
  end

  def add_to_pile(count)
    update remaining: (remaining + count)
  end

  def json(game_record, turn)
    if name == 'ruins' || name == 'knights'
      top_card = mixed_game_cards.first
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
    else
      card_cost = calculated_cost(game_record, turn)
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
end
