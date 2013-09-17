class GameCreator

  attr_accessor :game

  def initialize(player_ids, proposer)
    @player_ids = player_ids
    @proposer = proposer
  end

  def create
    @game = Game.create proposer_id: @proposer
    add_players
    add_game_cards
    add_player_decks
    draw_hands
    TurnChanger.new(@game).first_turn
    @game.reload
  end

  private

  def add_players
    players = Player.where id: @player_ids
    players.update_all current_game: @game.id
    players.shuffle.each_with_index do |player, index|
      GamePlayer.create(game_id: @game.id, player_id: player.id, turn_order: index+1, victory_tokens: 0)
    end
  end

  def add_game_cards
    %w[kingdom victory treasure miscellaneous].each do |card_type|
      send("#{card_type}_cards").each do |card|
        starting_count = card.starting_count(@game)
        game_card = GameCard.create(game_id: @game.id, card_id: card.id, remaining: starting_count)
        add_ruins(game_card, starting_count) if card.name == 'ruins'
      end
    end
  end

  def add_player_decks
    cards = starting_deck
    @game.game_players.each do |player|
      cards.shuffle.each_with_index do |card, index|
        PlayerCard.create(game_player_id: player.id, card_id: card.id, card_order: index+1, state: 'deck')
      end
    end
  end

  def draw_hands
    @game.game_players.each do |player|
      CardDrawer.new(player).draw(5, false)
    end
  end

  def kingdom_cards
    Card.card_type(:kingdom).shuffle.take(10)
  end

  def victory_cards
    cards = %w[estate duchy province]
    cards << 'colony' if prosperity_game?
    Card.card_name(cards)
  end

  def treasure_cards
    cards = %w[copper silver gold]
    cards << 'potion' if @game.has_potions?
    cards << 'platinum' if prosperity_game?
    cards << 'spoils' if @game.has_spoils?
    Card.card_name(cards)
  end

  def miscellaneous_cards
    cards = [Card.by_name('curse')]
    cards << Card.by_name('ruins') if ruins_game?
    cards << Card.by_name('madman') if hermit_game?
    cards << Card.by_name('mercenary') if urchin_game?
    cards
  end

  def starting_deck
    deck = [Card.by_name('copper')]*7
    if dark_ages_game?
      deck << Card.by_name('hovel')
      deck << Card.by_name('necropolis')
      deck << Card.by_name('overgrown_estate')
    else
      deck += ([Card.by_name('estate')]*3)
    end
  end

  def add_ruins(ruins_card, starting_count)
    ruins = []
    %w(abandoned_mine ruined_library ruined_market ruined_village survivors).each do |card_name|
      ruins += ([Card.by_name(card_name)] * 10)
    end
    ruins.shuffle.take(starting_count).each do |ruin, index|
      MixedGameCard.create(game_card: ruins_card, card: ruin, card_order: index, card_type: 'ruins')
    end
  end

  def prosperity_game?
    @prosperity_game ||= @game.cards_by_set('prosperity').count >= random_number
  end

  def random_number
    @random_number ||= (rand 10) + 1
  end

  def dark_ages_game?
    @game.cards_by_set('dark_ages').count >= (rand(10)+1)
  end

  def ruins_game?
    @ruins_game ||= @game.game_cards.select{ |game_card| game_card.card.looter_card? }.count > 0
  end

  def hermit_game?
    @hermit_game ||= @game.game_cards.select{ |game_card| game_card.card.name == 'hermit' }.count > 0
  end

  def urchin_game?
    @urchin_game ||= @game.game_cards.select{ |game_card| game_card.card.name == 'urchin' }.count > 0
  end

end
