class Game < ActiveRecord::Base
  has_many :game_players
  has_many :game_cards

  attr_accessor :players

  def add_players(player_ids)
    players = Player.where(id: player_ids)
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
    game_cards.collect(&:card).select{ |card| card.kingdom? }
  end

  def players
    game_players.collect(&:player)
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
        PlayerDeck.create(game_player_id: player.id, card_id: card.id, card_order: index+1, state: 'deck')
      end
    end
  end

end
