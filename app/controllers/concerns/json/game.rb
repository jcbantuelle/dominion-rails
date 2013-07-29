module Json::Game

  include Json::Helper, Json::GameLog

  def refresh_game_json(game, player)
    {
      action: 'refresh',
      kingdom_cards: game_cards(game, 'kingdom'),
      common_cards: common_cards(game)
    }.merge(game_area(game, player)).to_json
  end

  def end_turn_json(game, player)
    {
      action: 'end_turn',
      log: end_turn_log(game, player)
    }.merge(game_area(game, player)).to_json
  end

  def play_card_json(game, player, card_player)
    {
      action: 'play_card',
      log: card_player.log(player)
    }.merge(game_area(game, player)).to_json
  end

  private

  def game_area(game, player)
    game_player = game.game_player(player.id)
    {
      current_turn: game.current_turn,
      deck_count: game_player.deck.count,
      discard_count: game_player.discard.count,
      hand: sorted_hand(game_player),
      my_turn: same_player?(game.current_player.player, player)
    }
  end

end
