class DameJosephine < Knight

  def type
    [:action, :attack, :knight, :victory]
  end

  def value(deck)
    2
  end

  def results(deck)
    card_html
  end

  def play(game, clone=false)
  end

  def trash_self(game)
    card_to_trash = game.current_player.find_card_in_play('dame_josephine')
    CardTrasher.new(game.current_player, [card_to_trash]).trash unless card_to_trash.nil?
  end

end
