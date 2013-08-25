class Card < ActiveRecord::Base

  scope :card_type, ->(card_type) { where({card_type => true}) }
  scope :card_name, ->(card_name) { where(name: card_name) }
  scope :end_game_cards, ->{ where(name: %w[province colony])}

  after_find :load_card_module

  attr_accessor :log_updater

  def self.by_name(card_name)
    card_name(card_name).first
  end

  def load_card_module
    extend name.classify.constantize
  end

  def playable?
    respond_to? :play
  end

  def treasure_card?
    type.include?(:treasure)
  end

  def action_card?
    type.include?(:action)
  end

  def attack_card?
    type.include?(:attack)
  end

  def duration_card?
    type.include?(:duration)
  end

  def type_class
    type.map(&:to_s).join(' ')
  end

  def victory_card_count(game)
    game.player_count < 3 ? 8 : 12
  end

  def belongs_to_set?(set)
    self.set == set
  end

  def card_html
    "<span class=\"#{type_class}\">#{name.titleize}</span>".html_safe
  end

  def play_log(player, game)
    @log_updater = LogUpdater.new game
    @log_updater.card_action(player, self, 'play')
  end

  def gain_card(game, player, name, destination)
    card = Card.by_name(name)
    game_card = game.game_cards.by_card_id(card.id)
    card_gainer = CardGainer.new(game, player, game_card.id)
    card_gainer.gain_card(destination)
  end

  def give_card_to_player(game, player, card_name, destination)
    game_card = find_game_card(game, card_name)
    CardGainer.new(game, player, game_card.id).gain_card(destination)
  end

  def find_game_card(game, card_name)
    card = Card.by_name card_name
    game.game_cards.by_card_id(card.id).first
  end

  def market(game)
    card_drawer = CardDrawer.new(game.current_player)
    card_drawer.draw(1)
    game.current_turn.add_actions(1)
    game.current_turn.add_buys(1)
  end

end
