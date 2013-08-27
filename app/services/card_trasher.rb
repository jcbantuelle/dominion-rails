class CardTrasher

  def initialize(cards)
    @cards = cards
    @player = @cards.first.game_player
    @game = @player.game
  end

  def trash(source=nil)
    @cards.each do |player_card|
      GameTrash.create game: @game, card: player_card.card
      player_card.destroy
    end
    LogUpdater.new(@player.game).trash(@player, @cards, source)
  end

end
