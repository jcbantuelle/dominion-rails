class Game < ActiveRecord::Base
  has_many :game_players, ->{ ordered }, dependent: :destroy
  has_many :game_cards, dependent: :destroy
  has_many :players, foreign_key: 'current_game'
  has_many :turns, dependent: :destroy
  belongs_to :proposer, class_name: 'Player', foreign_key: 'proposer_id'

  before_destroy { |record| record.players.update_all(current_game: nil) }

  def player_count
    @player_count ||= game_players.count
  end

  def kingdom_cards
    game_cards.select{ |card| card.kingdom? }
  end

  def victory_cards
    game_cards.select{ |card| card.victory? }
  end

  def treasure_cards
    game_cards.select{ |card| card.treasure? }
  end

  def curse_card
    game_cards.select{ |card| card.name == 'curse' }.first
  end

  def accepted?
    game_players.all?(&:accepted?)
  end

  def timed_out_players
    game_players.timed_out.collect(&:player)
  end

  def game_player(player_id)
    game_players.where(player_id: player_id).first
  end

  def current_turn
    turns.where(turn: turn).first
  end

  def current_player
    current_turn.game_player
  end

  def end_game
    update_attribute :finished, true
  end

  def winner
    ranked_players.select{ |player| player.score == ranked_players.first.score }.map(&:username).join(' & ')
  end

  def ranked_players
    @ranked_players ||= game_players.sort{ |p1, p2| p2.score <=> p1.score }
  end

  def has_potions?
    game_cards.select{ |game_card|
      game_card.cost(self)[:potion].present?
    }.count > 0
  end

end
