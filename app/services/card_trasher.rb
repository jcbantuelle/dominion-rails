class CardTrasher

  def initialize(cards)
    @cards = cards
    @player = @cards.first.game_player
    @game = @player.game
  end

  def trash(source=nil)
    @cards.each do |game_card|
      GameTrash.create game: @game, card: game_card.card
      game_card.destroy
    end
    LogUpdater.new(@player.game).trash(@player, @cards, source)
  end

end
