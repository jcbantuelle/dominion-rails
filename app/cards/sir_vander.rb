class SirVander < Knight

  def play(game, clone=false)
  end

  def trash_self(game)
    card_to_trash = game.current_player.find_card_in_play('sir_vander')
    CardTrasher.new(game.current_player, [card_to_trash]).trash unless card_to_trash.nil?
  end

  def trash_reaction(game, player)
    give_card_to_player(game, player, 'gold', 'discard')
  end

end
