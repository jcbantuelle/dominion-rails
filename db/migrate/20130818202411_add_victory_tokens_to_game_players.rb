class AddVictoryTokensToGamePlayers < ActiveRecord::Migration
  def change
    add_column :game_players, :victory_tokens, :integer
  end
end
