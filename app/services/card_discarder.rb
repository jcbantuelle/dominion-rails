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
    end
    LogUpdater.new(@player.game).discard(@player, @cards, source)
    discarded_cards
  end

end
