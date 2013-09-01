class Card < ActiveRecord::Base

  include Json::Game

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

  def victory_card?
    type.include?(:victory)
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

  def put_card_on_deck(game, player, card)
    player.deck.update_all ['card_order = card_order + 1']
    card.update state: 'deck', card_order: 1
    LogUpdater.new(game).put(player, [card], 'deck', false)
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

  def reveal_cards(game, player)
    player.deck.each do |card|
      @revealed << card
      done = process_revealed_card(card)
      break if done
    end

    continue_revealing(game, player) unless reveal_finished?(game, player)
  end

  def continue_revealing(game, player)
    player.shuffle_discard_into_deck
    reveal_cards(game, player)
  end

  def calculated_cost(game)
    CardCostCalculater.new(game, self).cost
  end

  def wait_for_response(game)
    while Game.unfinished_actions(game.id).count > 0 do
      sleep(1)
    end
  end

  def update_player_hand(game, player)
    hand_json = update_hand_json(game, player)
    WebsocketDataSender.send_game_data(player, game, hand_json)
  end

  def send_choose_cards_prompt(game, game_player, cards, message, maximum=0, minimum=0)
    action = TurnAction.create game: game, game_player: game_player
    action.update sent_json: choose_cards_json(action, cards, maximum, minimum, message)

    WebsocketDataSender.send_game_data(game_player.player, game, action.sent_json)
    action
  end

  def process_player_response(game, game_player, action)
    Thread.new {
      wait_for_response(game)
      action = TurnAction.find_uncached action.id
      process_action(game, game_player, action)
      action.destroy
      ActiveRecord::Base.clear_active_connections!
    }
  end

end
