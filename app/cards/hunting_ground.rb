module HuntingGround

  def starting_count(game)
    10
  end

  def cost(game, turn)
    {
      coin: 6
    }
  end

  def type
    [:action]
  end

  def play(game, clone=false)
    @card_drawer = CardDrawer.new(game.current_player)
    @card_drawer.draw(4)
  end

  def trash_reaction(game, player)
    options = [
      { text: 'Duchy', value: 'duchy' },
      { text: '3 Estates', value: 'estate' }
    ]
    action = TurnActionHandler.send_choose_text_prompt(game, player, options, "Gain a Duchy or 3 Estates?".html_safe, 1, 1)
    TurnActionHandler.process_player_response(game, player, action, self)
  end

  def process_action(game, game_player, action)
    if action.response == 'estate'
      3.times do
        CardGainer.new(game, game_player, 'estate').gain_card('discard')
      end
    elsif action.response == 'duchy'
      CardGainer.new(game, game_player, 'duchy').gain_card('discard')
    end
  end

end
