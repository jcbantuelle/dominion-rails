class CardTrasher

  def initialize(player, cards)
    @cards = cards
    @player = player
    @game = @player.game
  end

  def trash(source=nil, discard=nil)
    trashed_cards = []
    @cards.each do |player_card|
      trashed_cards << GameTrash.create(game: @game, card: player_card.card)
      player_card.destroy
    end
    LogUpdater.new(@player.game).trash(@player, @cards, source, discard)
    @cards.each do |player_card|
      market_square = @player.find_card_in_hand('market_square')
      unless market_square.nil?
        reaction_card = market_square.card
        reaction_card.reaction(@game, @player, reaction_card)
        TurnActionHandler.wait_for_card(reaction_card)
      end
      player_card.card.trash_reaction(@game, @player) if player_card.card.respond_to?(:trash_reaction)
    end
    trashed_cards
  end

end
