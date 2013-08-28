shared_context 'play card' do

  before(:each) do
    @card = Card.create name: card_name
    @game_player = GamePlayer.create
    @turn = Turn.create game_player: @game_player
    @game = Game.create turn_id: @turn.id
    @game_player.game = @game
    PlayerCard.create game_player: @game_player, card: @card, state: 'hand'

    log_updater = double 'log_updater'
    log_updater.stub(:get_from_card)
    @card.log_updater = log_updater

    LogUpdater.any_instance.stub(:draw)

    @subject = CardPlayer.new @game, @card.id
  end

end

shared_context 'gain card' do

  before(:each) do
    @card = Card.create name: card_name
    @game_player = GamePlayer.create
    @turn = Turn.create game_player: @game_player
    @game = Game.create turn_id: @turn.id
    @game_player.game = @game
    PlayerCard.create game_player: @game_player, card: @card, state: 'hand'
    @game_card = GameCard.create game: @game, card: @card, remaining: 10

    log_updater = double 'log_updater'
    log_updater.stub(:get_from_card)
    @card.log_updater = log_updater

    LogUpdater.any_instance.stub(:card_action)

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
    @card = Card.create name: card_name
    @game_player = GamePlayer.create
    @turn = Turn.create game_player: @game_player, turn: 1
    @game = Game.create turn_id: @turn.id
    @game_player.update game: @game
    PlayerCard.create game_player: @game_player, card: @card, state: 'duration'

    log_updater = double 'log_updater'
    log_updater.stub(:get_from_card)
    @card.log_updater = log_updater

    LogUpdater.any_instance.stub(:draw)
    LogUpdater.any_instance.stub(:end_turn)
    LogUpdater.any_instance.stub(:get_from_card)

    @subject = TurnChanger.new @game
  end

end
