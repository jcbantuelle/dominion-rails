shared_context 'card setup' do

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
