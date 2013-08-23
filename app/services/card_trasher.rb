class CardTrasher

  def initialize(card)
    @card = card
    @player = @card.game_player
    @game = @player.game
  end

  def trash
    GameTrash.create game: @game, card: @card.card
    @card.destroy
    LogUpdater.new(@player.game).trash(@player, [@card])
  end

end
