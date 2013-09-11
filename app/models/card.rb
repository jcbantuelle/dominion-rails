class Card < ActiveRecord::Base

  scope :card_type, ->(card_type) { where({card_type => true}) }
  scope :card_name, ->(card_name) { where(name: card_name) }
  scope :end_game_cards, ->{ where(name: %w[province colony])}

  after_find :load_card_module

  attr_accessor :log_updater, :play_thread, :attack_thread, :reaction_thread

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

  def looter_card?
    type.include?(:looter)
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
    CardGainer.new(game, player, card_name).gain_card(destination)
  end

  def put_card_on_deck(game, player, card, announce=true)
    player.deck.update_all ['card_order = card_order + 1']
    card.update state: 'deck', card_order: 1
    LogUpdater.new(game).put(player, [card], 'deck', false, announce)
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

  def play_card_multiple_times(game, game_player, card, count)
    count.times do |i|
      play_card(game, card.card_id, i > 0)
      ActiveRecord::Base.connection.clear_query_cache
      TurnActionHandler.refresh_game_area(game, game_player.player)
    end
  end

  def play_card(game, card_id, clone)
    card = CardPlayer.new(game, card_id, true, clone).play_card
    TurnActionHandler.wait_for_card(card)
  end

end
