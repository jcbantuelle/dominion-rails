class CardBuyer

  def initialize(game, card_id)
    @game = game
    @game.reload
    @card = @game.game_cards.find card_id
  end

  def buy_card
    move_to_player_discard
    @game.current_turn.buy_card @card.cost
  end

  def valid_buy?
    affordable? && @card.available?
  end

  def log(player)
    locals = { game: @game, player: player, card: @card }
    Renderer.new.render 'game/log/buy_card', locals
  end

  private

  def move_to_player_discard
    @card.update_attribute :remaining, @card.remaining - 1
    PlayerCard.create game_player_id: @game.current_player.id, card_id: @card.card_id, state: 'discard'
  end

  def affordable?
    @game.current_turn.coins >= @card.cost[:coin]
  end

end
