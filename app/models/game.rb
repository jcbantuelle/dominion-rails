class Game < ActiveRecord::Base
  has_many :game_players, dependent: :destroy
  has_many :game_cards, dependent: :destroy
  has_many :players, foreign_key: 'current_game'
  belongs_to :proposer, class_name: 'Player', foreign_key: 'proposer_id'

  before_destroy { |record| record.players.update_all(current_game: nil) }

  def add_players(player_ids)
    players = Player.where(id: player_ids)
    players.update_all(current_game: self.id)
    players.shuffle.each_with_index do |player, index|
      GamePlayer.create(game_id: self.id, player_id: player.id, turn_order: index+1)
    end
  end

  def generate_board
    generate_cards
    generate_decks
  end

  def player_count
    @player_count ||= game_players.count
  end

  def kingdom_cards
    game_cards.select{ |card| card.kingdom? }
  end

  def accept_player(player_id)
    game_players.where(player_id: player_id).first.update_attribute(:accepted, true)
  end

  def accepted?
    game_players.collect(&:accepted).all?{|accepted| accepted == true }
  end

  def timed_out_players
    game_players.timed_out.collect(&:player)
  end

  def self.generate(attributes)
    game = Game.create proposer_id: attributes[:proposer]
    game.add_players attributes[:players]
    game.generate_board
    game
  end

  def proposed_cards
    kingdom_cards.map{ |card|
      { name: card.name.titleize, type: card.type_class }
    }
  end

  def game_player(player_id)
    game_players.where(player_id: player_id).first
  end

  private

  def generate_cards
    Card.generate_cards.each do |card|
      GameCard.create(game_id: self.id, card_id: card.id, remaining: card.starting_count(self))
    end
  end

  def generate_decks
    cards = Card.generate_starting_deck
    game_players.each do |player|
      cards.shuffle.each_with_index do |card, index|
        PlayerCard.create(game_player_id: player.id, card_id: card.id, card_order: index+1, state: 'deck')
      end
    end
  end

end
