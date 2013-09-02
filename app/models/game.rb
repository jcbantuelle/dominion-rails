class Game < ActiveRecord::Base
  has_many :game_players, ->{ ordered }, dependent: :destroy
  has_many :game_cards, dependent: :destroy
  has_many :game_trashes, dependent: :destroy
  has_many :players, foreign_key: 'current_game'
  has_many :turns, ->{ ordered }, dependent: :destroy
  has_many :turn_actions, dependent: :destroy
  belongs_to :current_turn, class_name: 'Turn', foreign_key: 'turn_id'
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

  def current_player
    current_turn.game_player
  end

  def end_game
    update_attribute :finished, true
  end

  def winner
    top_score = ranked_players.first.score
    fewest_turns = ranked_players.first.turn_count
    winners = ranked_players.select{ |player| player.score == top_score && player.turn_count == fewest_turns }
    winners.map(&:username).join(' & ')
  end

  def ranked_players
    @ranked_players ||= game_players.sort{ |p1, p2|
      comp = p2.score <=> p1.score
      comp.zero? ? (p1.turn_count <=> p2.turn_count) : comp
    }
  end

  def has_potions?
    game_cards.select{ |game_card|
      game_card.card.cost(self)[:potion].present?
    }.count > 0
  end

  def has_spoils?
    spoils_cards = %w(bandit_camp)
    game_cards.select{ |card| spoils_cards.include?(card.name) }.count > 0
  end

  def cards_by_set(set)
    game_cards.select{ |card| card.belongs_to_set?(set) }
  end

  def self.find_uncached(game_id)
    uncached do
      find(game_id) if exists?(game_id)
    end
  end

  def self.unfinished_actions(game_id)
    uncached do
      find(game_id).turn_actions.unfinished?.count
    end
  end

end
