class SirDestry < Knight

  def play(game, clone=false)
    CardDrawer.new(game.current_player).draw(2)
  end

  def trash_self(game)
    card_to_trash = game.current_player.find_card_in_play('sir_destry')
    CardTrasher.new(game.current_player, [card_to_trash]).trash unless card_to_trash.nil?
  end

end
