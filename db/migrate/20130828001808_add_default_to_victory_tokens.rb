class AddDefaultToVictoryTokens < ActiveRecord::Migration
  def change
    change_column :game_players, :victory_tokens, :integer, default: 0
  end
end
