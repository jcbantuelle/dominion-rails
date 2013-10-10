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
    # @cards.each do |player_card|
    #   market_square = @player.find_card_in_hand('market_square')
    #   unless market_square.nil?
    #     reaction_card = market_square.card
    #     reaction_card.reaction(@game, @player)
    #     TurnActionHandler.wait_for_card(reaction_card)
    #   end
    #   player_card.card.trash_reaction(@game, @player) if player_card.card.respond_to?(:trash_reaction)
    # end
    discarded_cards
  end

end
