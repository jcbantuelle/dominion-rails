shared_context 'setup' do
  before(:each) do
    @card = Card.create name: card_name
    @game_player = GamePlayer.create turn_order: 1
    @turn = Turn.create game_player: @game_player, turn: 1
    @game = Game.create turn_id: @turn.id
    @game_player.update game: @game

    LogUpdater.any_instance.stub(:put)
    LogUpdater.any_instance.stub(:draw)
    LogUpdater.any_instance.stub(:trash)
    LogUpdater.any_instance.stub(:reveal)
    LogUpdater.any_instance.stub(:discard)
    LogUpdater.any_instance.stub(:end_turn)
    LogUpdater.any_instance.stub(:card_action)
    LogUpdater.any_instance.stub(:outpost_turn)
    LogUpdater.any_instance.stub(:get_from_card)
  end
end

shared_context 'play card' do
  before(:each) do
    PlayerCard.create game_player: @game_player, card: @card, state: 'hand'
    @subject = CardPlayer.new @game, @card.id
  end
end

shared_context 'gain card' do
  before(:each) do
    PlayerCard.create game_player: @game_player, card: @card, state: 'hand'
    @game_card = GameCard.create game: @game, card: @card, remaining: 10
    @subject = CardGainer.new @game, @game_player, @game_card.id
  end
end

shared_context 'victory card' do
  before(:each) do
    c = Card.create name: card_name
    @card = Card.find(c.id)
  end
end

shared_context 'duration' do
  before(:each) do
    PlayerCard.create game_player: @game_player, card: @card, state: 'duration'
    @subject = TurnChanger.new @game
  end
end

shared_context 'other players' do
  before(:each) do
    @other_players = []
    2.times do |i|
      @other_players << GamePlayer.create(game: @game, turn_order: i+2)
    end
  end
end
