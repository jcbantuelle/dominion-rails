class Game < ActiveRecord::Base
  has_many :game_players
  has_many :game_cards

  attr_accessor :players

  def add_players(players)
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

  private

  def generate_cards
    Card.generate_cards.each do |card|
      card_object = card.name.classify.constantize
      card_count = card_object.self.starting_count(self)
      GameCard.create(game_id: self.id, card_id: card.id, remaining: card_count)
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
