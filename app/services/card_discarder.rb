class CardDiscarder

  def initialize(player, cards)
    @cards = cards
    @player = player
    @game = @player.game
  end

  def discard(source=nil)
    discarded_cards = []
    @cards.each do |player_card|
      player_card.update state: 'discard'
      player_card.card.discard_reaction(@game, @player, :discard) if player_card.card.respond_to?(:discard_reaction)
    end
    LogUpdater.new(@player.game).discard(@player, @cards, source)
    discarded_cards
  end

end
